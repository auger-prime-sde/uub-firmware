#include <unistd.h>
#include "rd_interface_defs.h"
#include "sde_trigger_defs.h"

void plot_latency(const char *filename)
{
  //#define _GNU_SOURCE

  // Plot data from minicom capture file

  char line[132];
  int status, in_event, in_event_header, event_num, event_nm;
  size_t len = 0;
  ssize_t read;
  int adc[5], rd, ix, i;
  int start_offset, latency, latency0, latency1;
  double dt, x;
  int lobin = 400;
  int hibin = 1200;
  int nbins = hibin - lobin;
  int timed = 0;
  int glitch_buffer[10][3];
  int glitch_size = 100;
  bool glitch = false;

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
  TH1D *hLatency = new TH1D("hLatency","Latency;Time (us);#",100,0.,4000.);
  TH1D *hCLK0 = new TH1D("hCLK0","FCLK_CLK0 (MHz);Event;#",100,0.,100.);
  TH1D *hCLK1 = new TH1D("hCLK1","FCLK_CLK1 (MHz);Event;#",100,0.,100.);
  TH1D *hGlitch = new TH1D("hGlitch","Glitch;Event;#",100,0.,100.);

  hADC3->SetStats(0);
  hRD0->SetStats(0);


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
        printf("Beginning of event\n");
        in_event_header = 0;
	in_event = 1;
        ix = 0;
	hADC3->Reset();
        hADC3->SetLineWidth(1);
	hADC3->SetLineColor(kBlack);

	hRD0->Reset();
        hRD0->SetLineWidth(1);
	hRD0->SetLineColor(kBlack);
      }
    else if (strncmp(line,">>>>>>>> END OF EVENT >>>>>>>>",29) == 0)
      {
        printf("End of event\n");
        if (glitch) hGlitch->Fill(event_num+.5,1);
	in_event = 0;
	event_num ++;
        glitch = false;

	// Draw all the histograms
	pad0->cd();
	hADC3->Draw();

	pad1->cd();
	hRD0->Draw();

	pad2->cd();
        hGlitch->Draw();

	pad3->cd();
        hCLK0->Draw();

	pad4->cd();
	hLatency->Draw();

	pad5->cd();
        hCLK1->Draw();

        rd_canv->Modified();
	rd_canv->Update();
	sprintf(line,"event%4.4d.eps\000",event_num);
	rd_canv->SaveAs(line);

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
 	sscanf(line,"%d %d %d %d",
	       &start_offset, &latency, &latency0, &latency1);
        hLatency->Fill(latency);
        hCLK0->Fill(event_num+.5,120.*(double)latency0/(double)latency);
        hCLK1->Fill(event_num+.5,120.*(double)latency1/(double)latency);
      }
 
  else if (in_event)
    {
      sscanf(line,"%x %x %x %x %x %x",
             &adc[0],&adc[1],&adc[2],&adc[3],&adc[4],&rd);
      x = ix+.5;
      ix++;
      hADC3->Fill(x,double((adc[3] >> 16) & 0xfff));
      hRD0->Fill(x,double((rd >> 1) & 0xfff));

      // Look for glitches
      for (i=0; i<5; i++)
        {
          glitch_buffer[2*i][0] = glitch_buffer[2*i][1];
          glitch_buffer[2*i][1] = glitch_buffer[2*i][2];
          glitch_buffer[2*i][2] = (adc[i] & 0xfff);
          if (ix > 2)
            {
              if (((glitch_buffer[2*i][1]-glitch_buffer[2*i][0]) > glitch_size) &&
                  ((glitch_buffer[2*i][1]-glitch_buffer[2*i][2]) > glitch_size))
                {
                  glitch = true;
                  printf("Glitch in ADC %d  %d start_offset %d\n", 2*i, ix, start_offset);
                }
              if (((glitch_buffer[2*i][0]-glitch_buffer[2*i][1]) > glitch_size) &&
                  ((glitch_buffer[2*i][2]-glitch_buffer[2*i][1]) > glitch_size))
                {
                  glitch = true;
                  printf("Glitch in ADC %d  %d start_offset %d\n", 2*i, ix, start_offset);
                }
            }

          if (ix > 2)
            {
              glitch_buffer[2*i+1][0] = glitch_buffer[2*i+1][1];
              glitch_buffer[2*i+1][1] = glitch_buffer[2*i+1][2];
              glitch_buffer[2*i+1][2] = ((adc[i] >> 16) & 0xfff);
              if (((glitch_buffer[2*i+1][1]-glitch_buffer[2*i+1][0]) > glitch_size) &&
                  ((glitch_buffer[2*i+1][1]-glitch_buffer[2*i+1][2]) > glitch_size))
                {
                  glitch = true;
                  printf("Glitch in ADC %d  %d start_offset %d\n", 2*i+1, ix, start_offset);
                }
              if (((glitch_buffer[2*i+1][0]-glitch_buffer[2*i+1][1]) > glitch_size) &&
                  ((glitch_buffer[2*i+1][2]-glitch_buffer[2*i+1][1]) > glitch_size))
                {
                  glitch = true;
                  printf("Glitch in ADC %d  %d start_offset %d\n", 2*i+1, ix, start_offset);
                }
            }
        }
    }
  }

  fclose(inpfile);
}

