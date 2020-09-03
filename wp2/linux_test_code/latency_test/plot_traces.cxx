#include <unistd.h>
#include "rd_interface_defs.h"
#include "sde_trigger_defs.h"

void plot_traces(const char *filename)
{
  //#define _GNU_SOURCE

  // Plot data from minicom capture file

  char line[132];
  int status, in_event, in_event_header, event_num, event_nm;
  size_t len = 0;
  ssize_t read;
  int adc[5], rd, ix, i;
  int latency, latency0, rd_status, shwr_buf_num;
  double dt, x;
  int lobin = 400;
  int hibin = 1200;
  int nbins = hibin - lobin;
  int toread_rd_buf_num;
  int cur_rd_buf_num;
  int full_rd_bufs;
  int busy_rd_bufs;
  int parity0, parity1;
  int timeout;
  int timed = 0;
  int peaks[10], areas[10], saturateds[10];
  int v[10];
  int glitch_buffer[3];
  int glitch_size = 100;
  bool glitch = false;
  bool rd_glitch = false;

  FILE *inpfile = fopen(filename,"r");
  if (inpfile == 0) {
    printf("Unable to open input file %s\n",filename);
    return;
  }
   
  gStyle->SetPaperSize(27.94,21.59);
  gStyle->SetOptStat(1111);
  gStyle->SetLineWidth(1);
  gStyle->SetTitleSize(0.06,"xy");
  gStyle->SetLabelSize(0.06,"xy");
  gStyle->SetTitleOffset(.75,"xy");
  gStyle->SetNdivisions(110,"y");

  TCanvas *rd_canv = new TCanvas("rd_canv",
				      "Showers",
				      100,10,1800,900);
  TH1D *hADC3 = new TH1D("hADC3","Spare ADC;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hRD0 = new TH1D("hRD0","RD0;Bin;ADC value",nbins,lobin,hibin);
  //  TH1D *hRD1 = new TH1D("hRD1","RD1;Bin;ADC value",nbins,lobin,hibin);
  TH1D *hDT = new TH1D("hDT","Interval;Time (s);#",100,0.,0.5);
  TH1D *hLatency = new TH1D("hLatency","Latency;Time (us);#",100,0.,2000.);
  TH1D *hDLatency = new TH1D("hDLatency","Latency;Time (us);#",100,0.,2000.);
  TH1D *hErrors = new TH1D("hErrors","Errors;Event;Error Code",1000,0.,1000.);
  TH1D *hGlitch = new TH1D("hGlitch","Glitch;Event;#",1000,0.,1000.);
  //  TH1D *hPeak = new TH1D("hPeak","Peak;Event #; Peak",1000,0.,1000.);

  hADC3->SetStats(0);
  hRD0->SetStats(0);
  hDT->SetStats(0);


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
        hADC3->SetLineWidth(1);
	hADC3->SetLineColor(kBlack);

	hRD0->Reset();
        hRD0->SetLineWidth(1);
	hRD0->SetLineColor(kBlack);

	//hRD1->Reset();
        //hRD1->SetLineWidth(1);
	//hRD1->SetLineColor(kBlack);
      }
    else if (strncmp(line,">>>>>>>> END OF EVENT >>>>>>>>",29) == 0)
      {
        //        printf("End of event\n");
        if (glitch) hGlitch->Fill(event_num+.5,1);
        if (rd_glitch) hGlitch->Fill(event_num+.5,2);
	in_event = 0;
	event_num ++;
        glitch = false;
        rd_glitch = false;

	// Draw all the histograms
	pad0->cd();
	hADC3->Draw();

	pad1->cd();
	hRD0->Draw();

	pad2->cd();
        //hRD1->Draw();
        hGlitch->Draw();

	pad3->cd();
        hDT->Draw();
	//hPeak->Draw();

	pad4->cd();
	hLatency->Draw();

	pad5->cd();
        //	hErrors->Draw();
        hDLatency->Draw();

        rd_canv->Modified();
	rd_canv->Update();
	sprintf(line,"event%4.4d.eps\000",event_num);
	rd_canv->SaveAs(line);

        if (timed)
          //          sleep(1);
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
	       &latency0, &shwr_buf_num, &latency, &rd_status, &dt);
        hLatency->Fill(latency);
        hDLatency->Fill(latency-latency0);
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

        fgets(line,132,inpfile);
 	sscanf(line,"%x %x %x %x %x %x %x %x %x %x",
	       &v[0], &v[1], &v[2], &v[3], &v[4],
	       &v[5], &v[6], &v[7], &v[8], &v[9]);

  for (i=0; i<10; i++)
    {
      peaks[i] = (v[i] >> SHWR_PEAK_SHIFT) & SHWR_PEAK_MASK;
      areas[i] = (v[i] & SHWR_AREA_MASK);
      saturateds[i] = (v[i] >> SHWR_SATURATED_SHIFT) & 1;
    }
  //        hArea->Fill(event_num+.5,areas[7]);
  //    hPeak->Fill(event_num+.5,peaks[7]);
      }
    else if (in_event)
      {
	sscanf(line,"%x %x %x %x %x %x",
	       &adc[0],&adc[1],&adc[2],&adc[3],&adc[4],&rd);
	x = ix+.5;
        ix++;
	hADC3->Fill(x,double((adc[3] >> 16) & 0xfff));
	hRD0->Fill(x,double((rd >> 1) & 0xfff));
	// hRD1->Fill(x,double((rd >> 17) & 0xfff));

        // Look for glitches
        glitch_buffer[0] = glitch_buffer[1];
        glitch_buffer[1] = glitch_buffer[2];
        glitch_buffer[2] = ((adc[3] >> 16) & 0xfff);
        if (((glitch_buffer[1]-glitch_buffer[0]) > glitch_size) &&
            ((glitch_buffer[1]-glitch_buffer[2]) > glitch_size))
          glitch = true;
        if (((glitch_buffer[0]-glitch_buffer[1]) > glitch_size) &&
            ((glitch_buffer[2]-glitch_buffer[1]) > glitch_size))
          glitch = true;

        // Now specifically look for readout glitches
        if (((adc[3] >> 16) & 0xfff) != ((adc[4] >> 16) & 0xfff))
          rd_glitch = true;
      }
  }

  fclose(inpfile);
}

