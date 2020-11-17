#include <unistd.h>
#include "rd_interface_defs.h"

void plot_traces(const char *filename)
{
  //#define _GNU_SOURCE

  // Plot data from minicom capture file

  char line[132];
  int status, in_event, in_event_header, event_num, event_nm;
  size_t len = 0;
  ssize_t read;
  int adc[5], rd, ix, i;
  int latency, rd_status, shwr_buf_num;
  double dt, x;
  int lobin = 0;
  int hibin = 2047;
  int nbins = hibin - lobin;
  int toread_rd_buf_num;
  int cur_rd_buf_num;
  int full_rd_bufs;
  int busy_rd_bufs;
  int parity0, parity1;
  int timeout;
  int timed = 0;

  FILE *inpfile = fopen(filename,"r");
  if (inpfile == 0) {
    printf("Unable to open input file %s\n",filename);
    return;
  }
   
  gStyle->SetPaperSize(27.94,21.59);
  gStyle->SetOptStat(0);
  gStyle->SetLineWidth(3);
  gStyle->SetTitleSize(0.06,"xy");
  gStyle->SetLabelSize(0.06,"xy");
  gStyle->SetTitleOffset(.75,"xy");
  gStyle->SetNdivisions(110,"y");

  TCanvas *rd_canv = new TCanvas("rd_canv",
				      "Showers",
				      100,10,1800,900);
  TH1D *hADC3 = new TH1D("hADC3","Spare AD ;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hRD0 = new TH1D("hRD0","RD0;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hRD1 = new TH1D("hRD1","RD1;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hDBG1 = new TH1D("hDBG1","DBG1;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hDBG2 = new TH1D("hDBG2","DBG2;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hDBG3 = new TH1D("hDBG3","DBG3;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hDBG4 = new TH1D("hDBG4","DBG4;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hDBG5 = new TH1D("hDBG5","DBG5;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hSDBG1 = new TH1D("hSDBG1","DBG1;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hSDBG2 = new TH1D("hSDBG2","DBG2;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hSDBG3 = new TH1D("hSDBG3","DBG3;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hSDBG4 = new TH1D("hSDBG4","DBG4;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hSDBG5 = new TH1D("hSDBG5","DBG5;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hDT = new TH1D("hDT","Interval;Time (s);#",100,0.,0.5);
  TH1D *hLatency = new TH1D("Latency","Latency;Time (us);#",100,0.,3000.);
  TH1D *hErrors = new TH1D("Errors","Errors;Event #,Error Code", 100,0.,100.);

  TPad *pad0 = new TPad("pad0","",0.02,0.01,0.48,0.33,0);
  TPad *pad1 = new TPad("pad1","",0.52,0.01,0.98,0.33,0);
  TPad *pad2 = new TPad("pad2","",0.02,0.34,0.48,0.66,0);
  TPad *pad3 = new TPad("pad3","",0.52,0.34,0.98,0.66,0);
  TPad *pad4 = new TPad("pad4","",0.02,0.67,0.48,0.99,0);
  TPad *pad5 = new TPad("pad5","",0.52,0.67,0.98,0.99,0);

  rd_canv->Draw();
  pad0->Draw();
  pad1->Draw();
  pad2->Draw();
  pad3->Draw();
  pad4->Draw();
  pad5->Draw();

  event_num = 0;
  printf("Type Enter to continue: ");
  gets(line);

  while (fgets(line,132,inpfile)) {
    if (strncmp(line,">>>>>>>> EVENT HEADER >>>>>>>>",30) == 0)
      {
        //        printf("Beginning of event header\n");
      in_event_header = 1;
      }
    else if (strncmp(line,">>>>>>>> START OF EVENT >>>>>>>>",32) == 0)
      {
        //        printf("Beginning of event\n");
        in_event_header = 0;
	in_event = 1;
        ix = 0;
	hADC3->Reset();
        hADC3->SetLineWidth(2);
	hADC3->SetLineColor(kBlack);

	hRD0->Reset();
        hRD0->SetLineWidth(2);
	hRD0->SetLineColor(kBlack);

	hRD1->Reset();
        hRD1->SetLineWidth(2);
	hRD1->SetLineColor(kBlack);

	hDBG1->Reset();
        hDBG1->SetLineWidth(2);
	hDBG1->SetLineColor(kBlack);
	hDBG2->Reset();
        hDBG2->SetLineWidth(2);
	hDBG2->SetLineColor(kRed);
	hDBG3->Reset();
        hDBG3->SetLineWidth(2);
	hDBG3->SetLineColor(kBlue);
	hDBG4->Reset();
        hDBG4->SetLineWidth(2);
	hDBG4->SetLineColor(kGreen);
	hDBG5->Reset();
        hDBG5->SetLineWidth(2);
	hDBG5->SetLineColor(kMagenta);

	hSDBG1->Reset();
        hSDBG1->SetLineWidth(2);
	hSDBG1->SetLineColor(kBlack);
	hSDBG2->Reset();
        hSDBG2->SetLineWidth(2);
	hSDBG2->SetLineColor(kRed);
	hSDBG3->Reset();
        hSDBG3->SetLineWidth(2);
	hSDBG3->SetLineColor(kBlue);
	hSDBG4->Reset();
        hSDBG4->SetLineWidth(2);
	hSDBG4->SetLineColor(kGreen);
	hSDBG5->Reset();
        hSDBG5->SetLineWidth(2);
	hSDBG5->SetLineColor(kMagenta);
      }
    else if (strncmp(line,">>>>>>>> END OF EVENT >>>>>>>>",29) == 0)
      {
        //        printf("End of event\n");
	in_event = 0;
	event_num ++;

	// Draw all the histograms
	pad0->cd();
	hADC3->Draw();

	pad1->cd();
	hRD0->Draw();

	pad2->cd();
	hRD1->Draw();

	pad3->cd();
        //	hDT->Draw();
        hDBG1->Draw();
        hDBG2->Draw("same");
        hDBG3->Draw("same");
        hDBG4->Draw("same");
        hDBG5->Draw("same");

	pad4->cd();
        //	hLatency->Draw();
        hSDBG1->Draw();
        hSDBG2->Draw("same");
        hSDBG3->Draw("same");
        hSDBG4->Draw("same");
        hSDBG5->Draw("same");

	pad5->cd();
	hErrors->Draw();

        rd_canv->Modified();
	rd_canv->Update();
        //	sprintf(line,"event%4.4d.eps\000",event_num);
	//rd_canv->SaveAs(line);
        if (timed)
          sleep(1);
        else
          {
            printf("Plotted event %d.", event_num);
            printf("  Type Enter to continue, q to quit, t for timed mode: ");
            gets(line);
            if (strncmp(line,"t",1) == 0) timed = 1;
            if (strncmp(line,"q",1) == 0) return;
          }
      }
    else if (in_event_header)
      {
 	sscanf(line,"%d %d %d %x %lf",
	       &event_nm, &shwr_buf_num, &latency, &rd_status, &dt);
        hLatency->Fill(latency);
        hDT->Fill(dt);
       toread_rd_buf_num = RD_BUF_RNUM_MASK & 
          (rd_status >> RD_BUF_RNUM_SHIFT);
        cur_rd_buf_num = RD_BUF_WNUM_MASK & 
          (rd_status >> RD_BUF_WNUM_SHIFT);
        full_rd_bufs = RD_BUF_FULL_MASK & 
          (rd_status >> RD_BUF_FULL_SHIFT);
        busy_rd_bufs = RD_BUF_BUSY_MASK &
          (rd_status >> RD_BUF_BUSY_SHIFT);
        parity0 = (1 << toread_rd_buf_num) &
          (rd_status >> RD_PARITY0_SHIFT);
        parity1 =  (1 << toread_rd_buf_num) &
          (rd_status >> RD_PARITY1_SHIFT);
         timeout = (1 << toread_rd_buf_num) &
          (rd_status >> RD_BUF_TIMEOUT_SHIFT); 

        if (parity0 != 0)
          {
          printf("Event %d Parity Error 0\n", event_num);
          hErrors->Fill(event_num+.5,1);
          }
        if (parity1 != 0)
          {
          printf("Event %d Parity Error 1\n", event_num);
          hErrors->Fill(event_num+.5,2);
          }
        if (timeout != 0)
          { 
          printf("Event %d RD buffer timeout\n", event_num);
          hErrors->Fill(event_num+.5,4);
          }
        if ((full_rd_bufs & (1 << toread_rd_buf_num)) == 0)
          {
          printf("Event %d No full RD buffer to read\n", event_num);
          hErrors->Fill(event_num+.5,8);
          }
      }
    else if (in_event)
      {
	sscanf(line,"%x %x %x %x %x %x",
	       &adc[0],&adc[1],&adc[2],&adc[3],&adc[4],&rd);
	x = ix+.5;
        ix++;
	hADC3->Fill(x,double((adc[3] >> 16) & 0xfff));
	hSDBG1->Fill(x,double((adc[3] >> 0) & 0x1));
	hSDBG2->Fill(x,double((adc[3] >> 1) & 0x1)+.05);
	hSDBG3->Fill(x,double((adc[3] >> 2) & 0x1)+.1);
	hSDBG4->Fill(x,double((adc[3] >> 3) & 0x1)+.15);
	hSDBG5->Fill(x,double((adc[3] >> 4) & 0x1)+.2);
	hRD0->Fill(x,double((rd >> 1) & 0xfff));
	hRD1->Fill(x,double((rd >> 17) & 0xfff));
        hDBG1->Fill(x,double((rd >> 13) & 0x1));
        hDBG2->Fill(x,double((rd >> 14) & 0x1)+.05);
        hDBG3->Fill(x,double((rd >> 15) & 0x1)+.1);
        hDBG4->Fill(x,double((rd >> 29) & 0x1)+.15);
        hDBG5->Fill(x,double((rd >> 30) & 0x1)+.2);
      }
  }

  fclose(inpfile);
}

