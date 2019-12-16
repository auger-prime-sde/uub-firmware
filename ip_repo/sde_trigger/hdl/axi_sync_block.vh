// axi_sync.vh
// 
// This is the code portion of the sde_trigger that is does the
// synchronization with the AXI bus.  
// 
// 22-Nov-2016 DFN Split off from sde_trigger_code.vh because that filee
//                 was getting too large.
// 07-Apr-2019 DFN Added scalers.
// 29-Apr-2019 DFN Added scaler resets.


   always @( posedge S_AXI_ACLK )
     begin
        if (slv_reg_wren &&
            ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] 
              == `SHWR_BUF_CONTROL_ADDR ))
          AXI_SHWR_CONTROL_WRITTEN <= 1;
        else
          AXI_SHWR_CONTROL_WRITTEN <= 0;

        if (slv_reg_wren &&
            ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] 
              == `MUON_BUF_CONTROL_ADDR ))
          AXI_MUON_CONTROL_WRITTEN <= 1;
        else
          AXI_MUON_CONTROL_WRITTEN <= 0;

        if (slv_reg_wren &&
            ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] 
              == `COMPATIBILITY_SCALER_A_COUNT_ADDR ))
          AXI_SCALER_A_COUNT_WRITTEN <= 1;
        else
          AXI_SCALER_A_COUNT_WRITTEN <= 0;

       if (slv_reg_wren &&
            ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] 
              == `COMPATIBILITY_SCALER_B_COUNT_ADDR ))
          AXI_SCALER_B_COUNT_WRITTEN <= 1;
        else
          AXI_SCALER_B_COUNT_WRITTEN <= 0;

       if (slv_reg_wren &&
            ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] 
              == `COMPATIBILITY_SCALER_C_COUNT_ADDR ))
          AXI_SCALER_C_COUNT_WRITTEN <= 1;
        else
          AXI_SCALER_C_COUNT_WRITTEN <= 0;

        AXI_REG_WRITE <= slv_reg_wren;
//	P6X[3] <= AXI_SHWR_CONTROL_WRITTEN;
     end

   // Synchronization with AXI registers for cases where glitches would be
   // problematic.  This should not be necessary for semi-static control registers.

//   synchronizer_32bit compatibility_global_control_sync
//     (.ASYNC_IN(COMPATIBILITY_GLOBAL_CONTROL),
//      .CLK(CLK120),
//      .SYNC_OUT(LCL_COMPATIBILITY_GLOBAL_CONTROL));
   synchronizer_1bit compatibility_global_control_sync
     (.ASYNC_IN(COMPATIBILITY_GLOBAL_CONTROL[0]),
      .CLK(CLK120),
      .SYNC_OUT(LCL_COMPATIBILITY_GLOBAL_CONTROL));

   synchronizer_32bit shwr_buf_control_sync(.ASYNC_IN(SHWR_BUF_CONTROL),
                                            .CLK(CLK120),
                                            .SYNC_OUT(LCL_SHWR_BUF_CONTROL));

   synchronizer_32bit led__control_sync(.ASYNC_IN(LED_CONTROL),
                                            .CLK(CLK120),
                                        .SYNC_OUT(LCL_LED_CONTROL));

   synchronizer_1bit control_written_sync(.ASYNC_IN(AXI_SHWR_CONTROL_WRITTEN),
                                          .CLK(CLK120),
                                          .SYNC_OUT(LCL_SHWR_CONTROL_WRITTEN));

   synchronizer_1bit 
     scaler_a_written_sync(.ASYNC_IN(AXI_SCALER_A_COUNT_WRITTEN),
                           .CLK(CLK120),.SYNC_OUT(LCL_SCALER_A_COUNT_WRITTEN));

   synchronizer_1bit 
     scaler_b_written_sync(.ASYNC_IN(AXI_SCALER_B_COUNT_WRITTEN),
                           .CLK(CLK120),.SYNC_OUT(LCL_SCALER_B_COUNT_WRITTEN));

   synchronizer_1bit 
     scaler_c_written_sync(.ASYNC_IN(AXI_SCALER_C_COUNT_WRITTEN),
                           .CLK(CLK120),.SYNC_OUT(LCL_SCALER_C_COUNT_WRITTEN));

   synchronizer_32bit
     random_mode_sync(.ASYNC_IN(RANDOM_TRIG_MODE),.CLK(CLK120),
                      .SYNC_OUT(LCL_RNDM_MODE));
   
   synchronizer_32bit shwr_trigid_sync
     (.ASYNC_IN(LCL_SHWR_BUF_TRIG_ID),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_BUF_TRIG_ID));

   synchronizer_32bit shwr_buf_status_sync
     (.ASYNC_IN(LCL_SHWR_BUF_STATUS),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_BUF_STATUS));

   synchronizer_32bit shwr_buf_start_sync
     (.ASYNC_IN(LCL_SHWR_BUF_START),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_BUF_START));

// Need to be careful here, SHWR_BUF_RNUM is in CLK120 domain, not AXI_CLK domain in
// in spite of common use of LCL prefix for other registers to mean CLK120 domain
   
   synchronizer_32bit shwr_buf_latency_sync
     (.ASYNC_IN(LCL_SHWR_BUF_LATENCY[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_BUF_LATENCY));

// Peak, area, & baseline
   synchronizer_32bit shwr_peak_area0
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA0[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA0));

   synchronizer_32bit shwr_peak_area1
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA1[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA1));

   synchronizer_32bit shwr_peak_area2
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA2[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA2));

   synchronizer_32bit shwr_peak_area3
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA3[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA3));

   synchronizer_32bit shwr_peak_area4
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA4[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA4));

   synchronizer_32bit shwr_peak_area5
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA5[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA5));

   synchronizer_32bit shwr_peak_area6
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA6[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA6));

   synchronizer_32bit shwr_peak_area7
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA7[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA7));

   synchronizer_32bit shwr_peak_area8
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA8[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA8));

   synchronizer_32bit shwr_peak_area9
     (.ASYNC_IN(LCL_SHWR_PEAK_AREA9[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_PEAK_AREA9));

   synchronizer_32bit shwr_baseline0
     (.ASYNC_IN(LCL_SHWR_BASELINE0[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_BASELINE0));

   synchronizer_32bit shwr_baseline1
     (.ASYNC_IN(LCL_SHWR_BASELINE1[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_BASELINE1));

   synchronizer_32bit shwr_baseline2
     (.ASYNC_IN(LCL_SHWR_BASELINE2[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_BASELINE2));

   synchronizer_32bit shwr_baseline3
     (.ASYNC_IN(LCL_SHWR_BASELINE3[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_BASELINE3));

   synchronizer_32bit shwr_baseline4
     (.ASYNC_IN(LCL_SHWR_BASELINE4[SHWR_BUF_RNUM]),
      .CLK(S_AXI_ACLK),.SYNC_OUT(SHWR_BASELINE4));

   // Scalers
      synchronizer_32bit scaler_a_count
     (.ASYNC_IN(LCL_SCALER_A_COUNT),
      .CLK(S_AXI_ACLK),.SYNC_OUT(COMPATIBILITY_SCALER_A_COUNT));

      synchronizer_32bit scaler_b_count
     (.ASYNC_IN(LCL_SCALER_B_COUNT),
      .CLK(S_AXI_ACLK),.SYNC_OUT(COMPATIBILITY_SCALER_B_COUNT));

      synchronizer_32bit scaler_c_count
     (.ASYNC_IN(LCL_SCALER_C_COUNT),
      .CLK(S_AXI_ACLK),.SYNC_OUT(COMPATIBILITY_SCALER_C_COUNT));


   // Test ADC outputs
   synchronizer_32bit adc0_test_sync
     (.ASYNC_IN({4'b0000,ADC0[2*`ADC_WIDTH-1:`ADC_WIDTH],
                 4'b0000,ADC0[`ADC_WIDTH-1:0]}),
      .CLK(S_AXI_ACLK),.SYNC_OUT(ADC0_TEST));
   synchronizer_32bit adc1_test_sync
     (.ASYNC_IN({4'b0000,ADC1[2*`ADC_WIDTH-1:`ADC_WIDTH],
                 4'b0000,ADC1[`ADC_WIDTH-1:0]}),
      .CLK(S_AXI_ACLK),.SYNC_OUT(ADC1_TEST));
   synchronizer_32bit adc2_test_sync
     (.ASYNC_IN({4'b0000,ADC2[2*`ADC_WIDTH-1:`ADC_WIDTH],
                 4'b0000,ADC2[`ADC_WIDTH-1:0]}),
      .CLK(S_AXI_ACLK),.SYNC_OUT(ADC2_TEST));
   synchronizer_32bit adc3_test_sync
     (.ASYNC_IN({4'b0000,ADC3[2*`ADC_WIDTH-1:`ADC_WIDTH],
                 4'b0000,ADC3[`ADC_WIDTH-1:0]}),
      .CLK(S_AXI_ACLK),.SYNC_OUT(ADC3_TEST));
   synchronizer_32bit adc4_test_sync
     (.ASYNC_IN({4'b0000,ADC4[2*`ADC_WIDTH-1:`ADC_WIDTH],
                 4'b0000,ADC4[`ADC_WIDTH-1:0]}),
      .CLK(S_AXI_ACLK),.SYNC_OUT(ADC4_TEST));

`ifdef KEEP_FILTD
   // Test filtered ADC outputs
   synchronizer_32bit filt_pmt0_test_sync
     (.ASYNC_IN({2'b00,FILTD_PMT0,4'b0000,FILTB_PMT0}),
      .CLK(S_AXI_ACLK),.SYNC_OUT(FILT_PMT0_TEST));
   synchronizer_32bit filt_pmt1_test_sync
     (.ASYNC_IN({2'b00,FILTD_PMT1,4'b0000,FILTB_PMT1}),
      .CLK(S_AXI_ACLK),.SYNC_OUT(FILT_PMT1_TEST));
   synchronizer_32bit filt_pmt2_test_sync
     (.ASYNC_IN({2'b00,FILTD_PMT2,4'b0000,FILTB_PMT2}),
      .CLK(S_AXI_ACLK),.SYNC_OUT(FILT_PMT2_TEST));
`endif //  `ifdef KEEP_FILTD
 
   // These are mostly redundant, but may be useful for debugging
   // synchronizer_32bit shwr_buf_start0_sync
   //   (.ASYNC_IN(LCL_SHWR_BUF_START0),
   //    .CLK(S_AXI_ACLK),.SYNC_OUT(`SHWR_BUF_START0));
   // synchronizer_32bit shwr_buf_start1_sync
   //   (.ASYNC_IN(LCL_SHWR_BUF_START1),
   //    .CLK(S_AXI_ACLK),.SYNC_OUT(`SHWR_BUF_START1));
   // synchronizer_32bit shwr_buf_start2_sync
   //   (.ASYNC_IN(LCL_SHWR_BUF_START2),
   //    .CLK(S_AXI_ACLK),.SYNC_OUT(`SHWR_BUF_START2));
   // synchronizer_32bit shwr_buf_start3_sync
   //   (.ASYNC_IN(LCL_SHWR_BUF_START3),
   //    .CLK(S_AXI_ACLK),.SYNC_OUT(`SHWR_BUF_START3));

