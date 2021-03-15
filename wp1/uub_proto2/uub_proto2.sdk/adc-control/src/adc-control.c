//This program takes first part of traces to analyze if ADC are stuck, 
//and eventualy reset them
//This fires LED and takes trace, need to be without DAQ running.
//In the last step, the status of ADC should be in initialization only or
//fully integrated in DAQ, not an apart process. So to not interfere DAQ.
//
//COMPILE make trace_extractor ARM=1

#include <stdio.h>
#include <stdlib.h>
#include "read_evt.h"
#include "sde_trigger_defs.h"
#include <math.h>					//compile with -lm
#include <signal.h>

#define N_MAX_SAMP 600	//<667 to avoid possible signal after trigger
#define N_EVT 100		//Number of events to smooth data.

//Global...
int min_base=250; //min range, ie 100 ADC
int max_base=350; //max range, ie 500 ADC
float min_stdev=0.01; //min std_deviation of signal, for plain signal detection
float max_stdev=2.5; //max std_deviation of signal, for toggling detection
//view default values below


main(int argc,char *argv[]){
  uint32_t *regs;

  int flag,n,i,j,l,ch,s;
  int offset,saturated,res,ret,reset=0;
  struct shwr_evt_complete evt;
  struct shwr_evt_raw *ev;
  struct shwr_evt_extra *ev_extra;

	if(argc==6){ //option by arguments
		//N_EVT=atoi(argv[1]); //Number of measurements, ie 100 
		min_base=atoi(argv[1]); //min range, ie 100 ADC
		max_base=atoi(argv[2]); //max range, ie 500 ADC
		min_stdev=atof(argv[3]); //min std_deviation of signal, for plain signal detection
		max_stdev=atof(argv[4]); //max std_deviation of signal, for toggling detection
		reset=atoi(argv[5]);// If 1 reset, if 0 no reset in case of ADC stuck
	} 
	else if(argc==2 || argc==3 || argc==4 || argc==5 || argc>6){
		if(argv[1][0]=='-' && argv[1][1]=='h'){	//-h or -help
			printf("#################################################################\n");
			printf("# Preliminary tool to verify if ADC of UUB are stuck or not     #\n");
			printf("# HELP: adc-check2 min_base max_base min_stdev max_stdev reset  #\n");
			printf("# min_base: baseline low limit / max_base: baseline high limit  #\n");
			printf("# min_stdev: stdev low limit / max_stdev:stdev high limit       #\n");
			printf("# baseline limits to know when adc stucks outside normal range  #\n");
			printf("# min_stdev to detect ADC stuck in one unique value             #\n");
			printf("# max_stdev to detect ADC toggling between two values           #\n");
			printf("# Reset enables with one the reset if ADC are stuck, 0=noreset  #\n");
			printf("# If without arguments, default values are 250 350 0.01 2.5 0   #\n");
			printf("# A.Travaini (Based on R.Sato soft)- 2019 - andres@auger.org.ar #\n");
			printf("#################################################################\n");
			exit(0);
		}
		else{
			printf(">>> HELP: adc_check -h <<<\n");
			exit(0);
		}
	}
	else{	//default values
		//N_EVT=100; //Number of measurements, ie 100 
		min_base=200; //min range, ie 100 ADC
		max_base=350; //max range, ie 500 ADC
		min_stdev=0.01; //min std_deviation of signal, for plain signal detection
		max_stdev=2.5; //max std_deviation of signal, for toggling detection
		reset=0;
	}
 

	float adc_values[10][N_MAX_SAMP*N_EVT]={0.0};

	//system("touch /home/root/daq/no_run");	//create flag file
	//system("killall -quit control 2>&1");	//Stop DAQ
	usleep(100000);
	//printf(">>> ADC Check program. Tells if ADC is stuck or toggling. <<<\n");
	//printf("Columns: ADC number - baseline mean - baseline stdev - status\n");
	//system("date");

	//int ch;
    if(read_evt_init()==0){   //open memory allocation that permits trigger control
		n=0;
		regs=(uint32_t *)read_evt_get_sde_trig_registers(); 		
		for(l=0;l<N_EVT;l++){
			
			//Pull down HV of PMT.............................
			//ret=system("slowc -p 1 -v 0 -p 2 -v 0 -p 3 -v 0");
			//if (WIFSIGNALED(ret) && (WTERMSIG(ret) == SIGINT || WTERMSIG(ret) == SIGQUIT))
			//	break; //For system to receive interrupting signals, from manual pages
			//Pull down HV of PMT.............................

			LED_trigger(regs);    //Trigger with LED trigger, so you dont need signal to see baseline performance
			flag=read_evt_read(&evt);
			ev=&(evt.raw);
			ev_extra=&(evt.extra);	//
			saturated=0;
			if(flag==0){
				for(s=0;s<5;s++)
					if(((ev_extra->AREA_PEAK[s] & 0x80000000)>>31)==1)
						saturated++;
				if(saturated==0){			//if not saturated event(put to all channels later)
					for(i=0;i<N_MAX_SAMP;i++){        //Just take trace before trigger(<667) if triggering with signal
						offset=(i+ev->trace_start) & (SHWR_NSAMPLES - 1);
						for(ch=0;ch<5;ch++){	//sweep all channels  
							//LG channel, 12 bits of ADC, bit 0 to 11.
							adc_values[ch*2][i+l*N_MAX_SAMP]=(float)(ev->fadc_raw[ch][offset] & 0xFFF);    
							//HG channel, 12 bits of ADC, bit 16 to 27.     
							adc_values[ch*2+1][i+l*N_MAX_SAMP]=(float)((ev->fadc_raw[ch][offset]>>16) & 0xFFF);   
						}
					}
				}
				else{
					printf("At least one saturated ADC, can't measure...\n");
					exit(0);
				}
			}//if
		}
    }//IF
	res=ADC_status(&adc_values);
	
	if(res>0){			//System call to reset ADC
		//printf("At least one bad ADC...     %d\n",reset);
		printf("At least one bad ADC...\n");
		if(reset==1){
			printf("Rebooting all ADC...\n");
			ret=system("adc-restart");
			//if (WIFSIGNALED(ret) && (WTERMSIG(ret) == SIGINT || WTERMSIG(ret) == SIGQUIT))
			//	break; //For system to receive interrupting signals, from manual pages
			usleep(10000);
		}
		else
			printf("Not rebooting...\n");
		reset=0;
		res=0;
	}
	//IF needed restor HV values for PMT.........................
	
	//system("rm /home/root/daq/no_run");	//Remove flag file
	usleep(100000);
}    //main

int ADC_status(float * a){
	int i,j,res=0;
	float sum[10],mean[10];
	float quad_sum[10],std_dev[10];
	
	for(i=0;i<10;i++){	//sum
		sum[i]=0.0;
		for(j=0;j<N_MAX_SAMP*N_EVT;j++){
			sum[i]+=a[j+N_MAX_SAMP*N_EVT*i];
			}
		}
		
	for(i=0;i<10;i++){	//mean
		mean[i]=0.0;
		mean[i]=(float)sum[i]/(N_MAX_SAMP*N_EVT);
	}

	for(i=0;i<10;i++){	//std_dev
		std_dev[i]=0.0;
		quad_sum[i]=0.0;
		for(j=0;j<N_MAX_SAMP*N_EVT;j++)
			quad_sum[i]+=pow((a[j+N_MAX_SAMP*N_EVT*i]-mean[i]),2);
		std_dev[i]=sqrt(quad_sum[i]/(N_MAX_SAMP*N_EVT));
		if(i+1<10)
			printf("ADC#%02d:  %.1f  \t %3.02f\t",i+1,mean[i], std_dev[i]);
		if(i+1==10)
			printf("ADC#%02d:  %.1f  \t %3.02f\t", i+1,mean[i], std_dev[i]);
		
		if(std_dev[i]<=min_stdev || std_dev[i]>=max_stdev || mean[i]>=max_base || mean[i]<=min_base){
			res++;	//Flag to know if error
			printf("\tERROR ADC:");
			
			if(std_dev[i]<min_stdev){ //conditions to have error message.
				printf("Plain signal. ");
			}
			if(std_dev[i]>=max_stdev){ //conditions to have error message.
				printf("Toggling signal. ");
			}
			if(mean[i]>=max_base){ //conditions to have error message.
				printf("Baseline too high >%d. ",max_base);
			}
			if(mean[i]<=min_base){ //conditions to have error message.
				printf("Baseline too low <%d. ",min_base);
			}
			printf("\n");
		}
		else
			printf("\tADC OK.\n");
			
	}
	return(res);
}
 
int LED_trigger(uint32_t * regs){
  regs[SHWR_BUF_TRIG_MASK_ADDR]|=SHWR_BUF_TRIG_LED;//REG 128, BIT 16 UP. Enables Led trigger.
  regs[LED_CONTROL_ADDR]=0; //TURN OFF LEDS
  regs[LED_CONTROL_ADDR]=1; //Do led pulse now
  usleep(100);//if you do not wait, there is no reading
}//end function
