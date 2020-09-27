void plot_integral(char *filename)
{
#define _GNU_SOURCE
#define INTEGRAL_FRAC_BITS 11

  // Plot showers from minicom capture file

  char line[132];
  int status, in_event, event_num;
  size_t len = 0;
  ssize_t read;
  int ix, adc,adcd,baseline,integral,sintegral, iv;
  int nbins = 2048;
  int i, j, pk, nentries, rnum;
  int baseline3;
  double x, baseline_sag, baseline1, baseline2;
  int saturated[10], base[10], peak[10], area[10];

  FILE *inpfile = fopen(filename,"r");
  if (inpfile == 0) {
    printf("Unable to open input file %s\n",filename);
    return;
  }
   
  // Test computation of baseline sag
  int amp = 10000;
  //  int sag1 = (amp>>9) - (amp>>11) - (amp>>14);
  int sag1 = (amp>>10) - (amp>>12);
  int sag2 = amp*0.0008;
  printf("amp=%d  sag1=%d  sag2=%d\n",amp,sag1,sag2);

  gStyle->SetPaperSize(27.94,21.59);
  gStyle->SetOptStat(0);
  gStyle->SetLineWidth(3);
  gStyle->SetTitleSize(0.09,"xy");
  gStyle->SetLabelSize(0.09,"xy");
  gStyle->SetTitleOffset(.45,"xy");
  gStyle->SetNdivisions(110,"y");

  TCanvas *shower_canv = new TCanvas("shower_canv",
				      "Showers",
				      100,10,2200,1000);
  TH1D *hADC = new TH1D("hADC",";Bin;ADC value",nbins,0.,nbins);
  TH1D *hADCD = new TH1D("hADCD",";Bin;ADC value",nbins,0.,nbins);
  TH1D *hPEAK = new TH1D("hPEAK",";Bin;ADC peak value",nbins,0.,nbins);
  TH1D *hBASE = new TH1D("hBASE","FPGA baseline;Bin;ADC value",
			 nbins,0.,nbins);
  TH1D *hBASE2 = new TH1D("hBASE2","FPGA baseline;Bin;ADC value",
			 nbins,0.,nbins);
  TH1D *hBASE3 = new TH1D("hBASE3","FPGA baseline;Bin;ADC value",
			 nbins,0.,nbins);
  TH1D *hINT = new TH1D("hINT",";Bin;ADC value",nbins,0.,nbins);
  TH1D *hINT2 = new TH1D("hINT2","Offline integral;Bin;ADC value",
			 nbins,0.,nbins);
  TPad *padadc = new TPad("padadc","ADC",0.02,0.02,0.98,0.48,0);
  TPad *padint = new TPad("padint","Integral",0.02,0.52,0.98,0.98,0);

  shower_canv->Draw();
  padadc->Draw();
  padint->Draw();

  event_num = 0;
  printf("Type Enter to continue: ");
  gets(line);

  while (fgets(line,132,inpfile)) {
    if (strncmp(line,">>>>>>>>>> BEGINNING OF EVENT >>>>>>>>>>",40) == 0)
      {
	in_event = 1;
	sintegral = 0;
	hADC->Reset();
	hADCD->Reset();
	hPEAK->Reset();
	hBASE->Reset();
	hBASE2->Reset();
	hBASE3->Reset();
	hINT->Reset();
	hINT2->Reset();
        hADC->SetLineWidth(3);
        hADCD->SetLineWidth(3);
        hPEAK->SetLineWidth(3);
        hBASE->SetLineWidth(3);
        hBASE2->SetLineWidth(3);
        hBASE3->SetLineWidth(3);
        hINT->SetLineWidth(3);
        hINT2->SetLineWidth(3);
	hADC->SetLineColor(kBlack);
	hADCD->SetLineColor(kBlack);
	hPEAK->SetLineColor(kBlue);
	hBASE->SetLineColor(kRed);
	hBASE2->SetLineColor(kGreen);
	hBASE3->SetLineColor(kMagenta);
	hINT->SetLineColor(kRed);
	hINT2->SetLineColor(kBlack);
	//	hINT->SetMinimum(0.);
	//	hINT->SetMaximum(4000.);
	//	hADCD->SetMinimum(310.);
	//	hADCD->SetMaximum(340.);
	hADCD->SetAxisRange(650, 750, "X");
	hINT->SetAxisRange(650, 750, "X");

	baseline_sag = 0;
	// Get header information for the event
	for(i=0; i<10; i++)
	  {
	    fgets(line,132,inpfile);
	    sscanf(line,"%d %d %d %d %d %d", 
		   &ix, &saturated[i], &base[i], &peak[i], &area[i], &rnum);
	    //	    printf("ix=%d\n",ix);
	  }
      }
    else if (strncmp(line,"<<<<<<<<<< END OF EVENT <<<<<<<<<<",34) == 0)
      {
	in_event = 0;
	event_num ++;

	// Draw all the histograms
	padadc->cd();
	hADCD->Draw();
	hBASE->Draw("same");
	hBASE2->Draw("same");
	hBASE3->Draw("same");
	hPEAK->Draw("same");

	padint->cd();
	hINT->Draw();
	hINT2->Draw("same");

        shower_canv->Modified();
	shower_canv->Update();
	sprintf(line,"event%4.4d.eps\000",event_num);
	shower_canv->SaveAs(line);
	printf("Saturated=%d  Baseline=%7.3lf  Peak=%d  Area=%d  entries=%d  rnum=%d\n",
	       saturated[3], double(base[3])/16., peak[3], area[3], nentries, rnum);
	printf("Plotted event %d.  Type Enter to continue or q to quit: ",
	       event_num);
        nentries = 0;
	gets(line);
	if (strncmp(line,"q",1) == 0) return;

      }
    else if (in_event)
      {
	sscanf(line,"%d %d %d %d %d %d %d",
	       &ix,&adc,&adcd, &baseline, &baseline3 , &integral, &pk);
	nentries++;
	//	if (nentries < 10)
	//  printf("nentries=%d  ix=%d  adc=%d\n", nentries, ix, adc);
	x = ix+.5;
	baseline1 = double(baseline)/16.;
	baseline_sag = baseline_sag + (adcd-baseline1)*0.0008;
        baseline2 = baseline1 - baseline_sag;
	//	integral = iv & 0x7ffff;
	//	pk = (iv >> 19) & 0xfff;
	hADC->Fill(x,double(adc));
	hADCD->Fill(x,double(adcd));
	hPEAK->Fill(x-1.,baseline1+double(pk));
	hBASE->Fill(x,baseline1);
	hBASE2->Fill(x,baseline2);
	hBASE3->Fill(x-4.,double(baseline3)/16.);
	hINT->Fill(x-3.,double(integral));
	if ((x > 680.) && (x < 740.)) sintegral = sintegral+adcd-baseline2;
	hINT2->Fill(x,double(sintegral));
      }

  }

  fclose(inpfile);
}

