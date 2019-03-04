// time_tagging_intr.vh
//
// This file contains the main IP specific portion of the time_tagging interrupt code.
// It is extracted as a separate .vh file to encasulate most of our specific changes
// from the standard Vivado interrupt module into one file.
//
// 20-Feb-2019 DFN Initial version derived from sde_trigger_intr.vh

wire AXI_INTR;  // 1PPS synchronized to AXI clock
reg PREV_AXI_INTR;


// // Synchronize 1PPS signals to AXI clock

synchronizer_1bit PPS_synch(.ASYNC_IN(INTR),
                                     .CLK(S_AXI_ACLK),
                                     .SYNC_OUT(AXI_INTR));

// Generate edge triggered interrupt 1PPS signals.

always @ ( posedge S_AXI_ACLK )
  begin
     if ( S_AXI_ARESETN == 1'b0 | reg_intr_ack[i] == 1'b1)
       begin
	  intr <= 1'b0;
       end
     else
       begin
	  if (PREV_AXI_INTR == 0)
            intr <= AXI_INTR;
          else
            intr <= 0;
          PREV_AXI_INTR <= AXI_INTR;
       end

     // detects interrupt in any intr input 
     // Note that interrupts are merged here
     // detects intr ack in any reg_intr_ack reg bits
     if ( S_AXI_ARESETN == 1'b0 )
       begin
	  intr_all <= 1'b0;
       end
     else
       begin
	  intr_all <= | reg_intr_pending;
	  intr_ack_all <= | reg_intr_ack;
       end
  end
	   
 
   
   //---------------------------------------------------------------------
   // Hardware interrupt detection
   //---------------------------------------------------------------------
   
   // Detect interrupts for user selected number of interrupts
   // For clarity only positive level interrupt is implemented.
   
   always @ ( posedge S_AXI_ACLK )
     begin
	if ( S_AXI_ARESETN == 1'b0 | reg_intr_ack[i] == 1'b1)
	  begin
	     det_intr <= 1'b0;
	  end
	else
	  begin
	     if (intr == 1'b1)
	       begin
	          det_intr <= 1'b1;
	       end
	  end
     end
      
      // IRQ generation logic

      always @ ( posedge S_AXI_ACLK )
        begin
           if ( (S_AXI_ARESETN == 1'b0) || (intr_ack_all == 1'b1))
             begin
	        s_irq <= 1'b0;
             end
           else if (intr_all == 1'b1 && reg_global_intr_en[0] ==1'b1)
             begin
	        s_irq <= 1'b1;
             end
        end	

      assign irq = s_irq;



