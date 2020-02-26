
// Simple standalone test routine to interact with the sde_trigger PL.
//
// 26-Feb-2016 DFN Initial (reconstructed from lost code) version
//                 The initial version does not test interrupts - 
//                 to be restored later
// 11-Apr-2016 DFN Add simple polled DMA
// 29-Apr-2016 DFN Implement TRIGGER_INTERRUPT
// 30-Apr-2018 DFN Implement split shower & muon interrupts
// 04-Nov-2019 DFN Add MoPS and Random triggers
// 27-Dec-2019 DFN Remove now-obsolete DMA code to simplify program

#include "trigger_test_options.h"
#include "trigger_test.h"

#ifndef STAND_ALONE
  volatile u32 *trig_regs;
  volatile u32 *ttag_regs;
  volatile u32 *ifc_regs;
  volatile u32 *tstctl_regs;
#endif

volatile u32 shwr_mem_ptr[5];
volatile u32 muon_mem_ptr[2];
volatile u32 fake_event_ptr[2];
u32 shwr_mem_addr[5];
u32 muon_mem_addr[2];
u32 fake_event_addr[2];
volatile int nevents = 0;
volatile int missed_events = 0;
volatile int compat_sb_count = 0;
volatile int compat_sb_dlyd_count = 0;
volatile int compat_tot_count = 0;
volatile int compat_tot_dlyd_count = 0;
volatile int compat_totd_count = 0;
volatile int compat_totd_dlyd_count = 0;
volatile int compat_mops_count = 0;
volatile int compat_mops_dlyd_count = 0;
volatile int sb_count = 0;
volatile int sb_dlyd_count = 0;
volatile int rndm_count = 0;
volatile int rndm_dlyd_count = 0;
volatile int compat_ext_count = 0;
volatile int compat_ext_dlyd_count = 0;

// Shower memory buffers
volatile int readto_shw_buf_num = 0;
volatile int full_shw_rd_bufs[NUM_BUFFERS];
volatile int unpack_shw_buf_num = 0;
u32 shw_mem0[NUM_BUFFERS][SHWR_MEM_WORDS] __attribute__((aligned(128)));
u32 shw_mem1[NUM_BUFFERS][SHWR_MEM_WORDS] __attribute__((aligned(128)));
u32 shw_mem2[NUM_BUFFERS][SHWR_MEM_WORDS] __attribute__((aligned(128)));
u32 shw_mem3[NUM_BUFFERS][SHWR_MEM_WORDS] __attribute__((aligned(128)));
u32 shw_mem4[NUM_BUFFERS][SHWR_MEM_WORDS] __attribute__((aligned(128)));

// ADC traces & extra bits
u32 shw_mem[5][SHWR_MEM_WORDS];
u16 adc[10][SHWR_MEM_WORDS];
u16 filt_adc[3][SHWR_MEM_WORDS];
u8 flags[SHWR_MEM_WORDS];

// Muon memory buffers
u32 muon_mem0[MUON_MEM_WORDS] __attribute__((aligned(64)));
u32 muon_mem1[MUON_MEM_WORDS] __attribute__((aligned(64)));
u16 muon_adc[4][MUON_BURST_LEN][MUONS_PER_BUF];
u16 muon_seq_num[MUON_BURST_LEN][MUONS_PER_BUF];
u16 muon_trig_tags[MUONS_PER_BUF];
u32 muon_burst_start[MUONS_PER_BUF];
u32 muon_buffer_start;
u32 muon_buffer_end;
int mu_word_count;

u32 *mem_addr, *mem_ptr;
u32 start_offset[NUM_BUFFERS];
int toread_shwr_buf_num;
int toread_muon_buf_num;
int status;

#ifdef TRIGGER_INTERRUPT
static XScuGic IntController;	// Instance of the Interrupt Controller
static XScuGic_Config *IntCfgPtr;  // The config. parameters of the controller
#endif

volatile static int Shwr_Data_Read = 0;
volatile static int Muon_Data_Read = 0;
volatile static int prev_read = -1;
volatile static int ave_num_full = 0;
volatile static int ave_num_used = 0;
volatile static int max_num_full = 0;
volatile static int max_num_used = 0;

void trigger_test()
{
#ifdef TRIGGER_POLLED
  int cur_shwr_buf_num = 0;
  int full_shwr_bufs = 0;
  int cur_muon_buf_num = 0;
  int full_muon_bufs = 0;
  int cntrl_word = 0;
  int num_full;
  int shwr_status, muon_status;
  int latency;
#endif
  int id;

#ifdef SHWR_TRIGGERS
  int trigger_mask;
  int thr0, thr1, thr2;
  #ifdef COMPAT_SB_TRIGGER
    int compat_sb_trig_enab;
  #endif
  #ifdef SB_TRIGGER
    int sb_trig_enab;
  #endif
#ifdef LED_TRIGGER
    int led_trig_enab;
#endif
#endif

#ifdef MUON_TRIGGERS
  int muon_trig_enab;
  int muon_trigger_mask;
#endif
#ifdef DO_LED_PULSE
  int led_control, led_timer, led_pulsewid, led_delay;
  int seconds, prev_seconds, nanosec;
  double time, dt, prev_time;
#endif
  int i;
#ifdef USE_FAKE_SIGNAL
  int fake_adc[3];
  FILE *fake_event_file;
  u32 *mem_ptr0, *mem_ptr1, *mem_addr0, *mem_addr1;
#endif

  for (i=0; i<NUM_BUFFERS; i++)
    full_shw_rd_bufs[i] = 0;

  // Map registers & memory buffers
  map_registers();

  // Select any special test options.
  int test_options = 0;

  // Select fake or true GPS for 1pps
#ifdef USE_FAKE_GPS
  test_options = 1;
#endif

  // Select fake or true signals
#ifdef USE_FAKE_SIGNAL
  test_options = test_options | 2;
      // FAKE_SIGNAL_MODE & 0x1f == 7 means load fake data!
      if ((FAKE_SIGNAL_MODE & 0x1f) == 7) 
    {
      fake_event_file = fopen("/fake_event.txt","r");
      if (fake_event_file == 0) {
        printf("Unable to open input file fake_event.txt\n");
        return;
      }
      mem_ptr0 = (u32*) fake_event_ptr[0];
      mem_ptr1 = (u32*) fake_event_ptr[1];
      //     mem_ptr0 = mem_addr0;
      //mem_ptr1 = mem_addr1;
      for (i=0; i<SHWR_MEM_WORDS; i++)
        {
          fscanf(fake_event_file,"%d %d %d", 
                 &fake_adc[0], &fake_adc[1], &fake_adc[2]);
          //
          mem_ptr0[i] = fake_adc[0] | (fake_adc[1] << 16);
          mem_ptr1[i] = fake_adc[2];
          //          printf("Fake event: i=%d  fake_adcs=%x %x %x ptrs=%x %x\n",
          //     i, fake_adc[0], fake_adc[1], fake_adc[2], mem_ptr0[i], mem_ptr1[i]);
          // fflush(stdout);
         }
      // fclose(fake_event_file);
      //for (i=0; i<SHWR_MEM_WORDS; i++)
      //  {
          //          printf("Fake event: i=%d  fake_adcs=%x %x %x\n",
          //       i, mem_ptr0[i]&0x3ff, mem_ptr0[i]>>16, mem_ptr1[i]);
          //fflush(stdout);
      //   }
    }

#endif
#ifdef USE_FAKE_MUON
  test_options = test_options | 4;
#endif
  if (test_options != 0)
    {
      write_tstctl(0, test_options);
      status = read_tstctl(0);
      //	  status = read_ifc(2);
      //	  printf("ifc_reg = %x  ifc_reg[2] = %x\n",ifc_regs, status);
      //	  write_ifc(2, test_options);
      //	  status = read_ifc(2);
	  
      if (status != test_options) 
	printf("trigger_test: Error setting test options, wrote %x read %x\n",
	       test_options, status);

      write_tstctl(1, 0);  // Mode=0 is used as RESET

      write_tstctl(1, FAKE_SIGNAL_MODE);
      status = read_tstctl(1);
      //	  status = read_ifc(2);
      //	  printf("ifc_reg = %x  ifc_reg[2] = %x\n",ifc_regs, status);
      //	  write_ifc(2, test_options);
      //	  status = read_ifc(2);
	  
      if (status != FAKE_SIGNAL_MODE)
	printf("trigger_test: Error setting test mode, wrote %x read %x\n",
	       FAKE_SIGNAL_MODE, status);
    }

  // Set up trigger

  // Check for sane ID
  id = read_trig(ID_REG_ADDR);
  printf("trigger_test: id=%x\n",id);

  // Reset trigger
  write_trig(COMPATIBILITY_GLOBAL_CONTROL_ADDR,1);

  // Disable all shower triggers
  write_trig(SHWR_BUF_TRIG_MASK_ADDR,0);
  status = read_trig(SHWR_BUF_TRIG_MASK_ADDR);
  if (status != 0) printf("trigger_test: Error reading TRIG_MASK %x\n",status);

#ifdef TRIGGER_INTERRUPT
  // Initialize the interrupt controller driver so that it is ready to use.
  IntCfgPtr = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
  if (NULL == IntCfgPtr) 
    {
      printf("trigger_test: Failed to initialize interrupt controller\n");
      return;
    }
  status = XScuGic_CfgInitialize(&IntController, IntCfgPtr,
				 IntCfgPtr->CpuBaseAddress);
  if (status != XST_SUCCESS)
    {
      printf("trigger_test: Failed to initialize interrupt controller\n");
      return;
    }

  // Initialize the exception table
  Xil_ExceptionInit();

  // Connect the interrupt controller interrupt handler to the hardware
  // interrupt handling logic in the ARM processor.
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                               (Xil_ExceptionHandler) XScuGic_InterruptHandler,
                               (void *)&IntController);

  // Enable interrupts in the ARM
  Xil_ExceptionEnable();

  //	 Connect device driver handler that will be called when an
  //	 interrupt for the device occurs, the device driver handler performs
  //	 the specific interrupt processing for the device  
  status = 
    XScuGic_Connect(&IntController,
                    XPAR_FABRIC_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_SHWR_IRQ_INTR,
                    (Xil_ExceptionHandler)sde_shwr_intr_handler,
                    (void *)&IntController);
  if (status != XST_SUCCESS)
    {
      printf("trigger_test: Failed to connect to sde_shwr_intr_handler\n");
      return;
    }

  status = 
    XScuGic_Connect(&IntController,
                    XPAR_FABRIC_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_MUON_IRQ_INTR,
                    (Xil_ExceptionHandler)sde_muon_intr_handler,
                    (void *)&IntController);
  if (status != XST_SUCCESS)
    {
      printf("trigger_test: Failed to connect to sde_muon_intr_handler\n");
      return;
    }

  // Enable shower interrupts from the sde_trigger module.
  SDE_TRIGGER_EnableInterrupts((int *) SDE_SHWR_TRIGGER_INTR_BASE, 1);
  SDE_TRIGGER_EnableInterrupts((int *) SDE_MUON_TRIGGER_INTR_BASE, 1); 
	
  // Enable the interrupt from the trigger at the interrupt controller
  XScuGic_Enable(&IntController,
		 XPAR_FABRIC_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_SHWR_IRQ_INTR); 
  XScuGic_Enable(&IntController,
		 XPAR_FABRIC_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_MUON_IRQ_INTR); 

#endif  //TRIGGER_INTERRUPT

  config_trigger();  // Configure triggers
             
  enable_trigger_intr();  // Final enable of trigger interrupts (if defined)

  // Loop forever
  nevents = 0;
  while (nevents < MAX_EVENTS) {

#ifdef STAND_ALONE   // Seems to be a conflict on Linux
#ifdef TOGGLE_WATCHDOG
    map_ifc();
    write_ifc(3, 3);
    write_ifc(3, 2);
#endif
#endif
#ifdef TOGGLE_ADCPWD
    printf("Toggling ADCPWD\n");
    map_ifc();
    write_ifc(1, 2);  // Toggle ADCPWD (ex P64)
    write_ifc(2, 0);  // Toggle P65 in opposite phase
    write_ifc(1, 0);
    write_ifc(2, 1);
#endif

#ifdef DO_LED_PULSE
    //     disable_trigger_intr();

#ifdef DO_LED_NOW
    led_timer = led_timer+1;
    if (led_timer > 100000)
      {
        int loop_count = loop_count+1;
        write_trig(LED_CONTROL_ADDR, 0);
        led_timer = 0;
        led_pulsewid = LED_PULSWID0;
        if (loop_count % 2 == 1) led_pulsewid = LED_PULSWID1; 
        printf("Led_pulsewid = %d\n", led_pulsewid);
        led_control = (LED_DELAY0 << LED_DELAY_SHIFT) |
          (led_pulsewid << LED_PULSWID_SHIFT) | LED_NOW;
        write_trig(LED_CONTROL_ADDR, led_control);
      }
#else
    seconds = read_ttag(TTAG_PPS_SECONDS_ADDR);
    seconds = seconds & TTAG_SECONDS_MASK;
    if (seconds != prev_seconds) 
      {
        prev_seconds = seconds;
        int loop_count = loop_count+1;
        led_pulsewid = LED_PULSWID0;
        if (loop_count % 2 == 1) led_pulsewid = LED_PULSWID1;
        led_delay = LED_DELAY0;
        if (loop_count % 2 == 1) led_delay = LED_DELAY1; 
        printf("Led_pulsewid = %d at %d seconds\n", led_pulsewid, seconds);
        led_control = (led_delay << LED_DELAY_SHIFT) |
          (led_pulsewid << LED_PULSWID_SHIFT) | LED_ENAPPS;
        write_trig(LED_CONTROL_ADDR, led_control);
      }
#endif
    //    enable_trigger_intr();
#endif

#ifdef TRIGGER_POLLED
    // Is an interrupt pending?
    status = read_trig(SHWR_BUF_STATUS_ADDR);
    if ((SHWR_INTR_PEND_MASK & (status >> SHWR_INTR_PEND_SHIFT)) != 0)
      {
        //  printf("Shower buf: Interrupt pending\n");
        //printf("Trigger_test: Shower buf status %x  writing %d  to read %d  full %x  num full=%d\n",
        //     status, SHWR_BUF_WNUM_MASK & (status >> SHWR_BUF_WNUM_SHIFT),
        //     SHWR_BUF_RNUM_MASK & (status >> SHWR_BUF_RNUM_SHIFT), 
        //     SHWR_BUF_FULL_MASK & (status >> SHWR_BUF_FULL_SHIFT),
        //     0x7 & (status >> SHWR_BUF_NFULL_SHIFT));
        toread_shwr_buf_num = SHWR_BUF_RNUM_MASK & 
          (status >> SHWR_BUF_RNUM_SHIFT);
        cur_shwr_buf_num = SHWR_BUF_WNUM_MASK & 
          (status >> SHWR_BUF_WNUM_SHIFT);
        full_shwr_bufs = SHWR_BUF_FULL_MASK & 
          (status >> SHWR_BUF_FULL_SHIFT);
        num_full = 0x7 & (status >> SHWR_BUF_NFULL_SHIFT);
#ifndef VERBOSE_BUFFERS
        if (nevents%EVENT_COUNT_INTERVAL == 0)
          {
            //  printf("Trigger_test: Read %d events\n", nevents);
            printf("Trigger_test: Counts - Compat SB %d  Compat ToT %d",
                   compat_sb_count, compat_tot_count);
            printf("  Compat ToTd %d  SB %d  EXT %d",
                   compat_totd_count, sb_count, compat_ext_count);
            printf("  Compat MoPS %d  Rndm %d",
                   compat_mops_count, rndm_count);
            printf("  Compat SB dlyd %d  Compat ToT dlyd %d",
                   compat_sb_dlyd_count, compat_tot_dlyd_count);
            printf("  Compat ToTd dlyd %d  SB dlyd %d  EXT dlyd %d",
                   compat_totd_dlyd_count, sb_dlyd_count, 
                   compat_ext_dlyd_count);
            printf("  Compat MoPS dlyd %d  Rndm dlyd %d\n",
                   compat_mops_dlyd_count, rndm_dlyd_count);
            fflush(stdout);
          //          compat_sb_count = 0;
          //compat_tot_count = 0;
          //compat_totd_count = 0;
          //sb_count = 0;
          //compat_sb_dlyd_count = 0;
          //compat_tot_dlyd_count = 0;
          //compat_totd_dlyd_count = 0;
          //sb_dlyd_count = 0;
          }
        if ((toread_shwr_buf_num != ((prev_read+1) & 0x3)) && (prev_read != -1))
          {
            printf("Shower buf writing %d  to read %d  full %x  num full=%d  prev_read=%d",
                   cur_shwr_buf_num,toread_shwr_buf_num,
                   full_shwr_bufs,num_full,prev_read);
            printf(" ******** ERROR ******* (check scope not running)");
            printf("\n");  
            exit(1);
          }
#endif
#ifdef VERBOSE_BUFFERS
            printf("Shower buf writing %d  to read %d  full %x  num full=%d  prev_read=%d",
                   cur_shwr_buf_num,toread_shwr_buf_num,
                   full_shwr_bufs,num_full,prev_read);
        if ((toread_shwr_buf_num != ((prev_read+1) & 0x3)) && (prev_read != -1))
          {
            printf(" ******** ERROR ******* (check scope not running)");
            printf("\n");
            exit(1);
          }
        printf("\n");
        fflush(stdout);
#endif
        prev_read = toread_shwr_buf_num;
 
        // Do readout of buffer here ....
        //printf("Starting read_shw_buffers\n");
        read_shw_buffers();  // Read buffers to local memory
    	nevents++;

  #ifdef USE_FAKE_SIGNAL
      // FAKE_SIGNAL_MODE & 0x1f == 7 means load fake data!
      if ((FAKE_SIGNAL_MODE & 0x1f) == 7) 
      {
      mem_ptr0 = (u32*) fake_event_ptr[0];
      mem_ptr1 = (u32*) fake_event_ptr[1];
       for (i=0; i<SHWR_MEM_WORDS; i++)
        {
          status = fscanf(fake_event_file,"%d %d %d", 
                 &fake_adc[0], &fake_adc[1], &fake_adc[2]);
          // printf("fscanf status=%d\n",status);
          if (status == 3) {
            mem_ptr0[i] = fake_adc[0] | (fake_adc[1] << 16);
            mem_ptr1[i] = fake_adc[2];
          }
        }
       if (status != 3)
         {
           fclose(fake_event_file);
           fake_event_file = fopen("/fake_event.txt","r");
           //           nevents = MAX_EVENTS;
      }
      }
#endif
      latency = read_trig(SHWR_BUF_LATENCY_ADDR);
        printf("Event read latency = %d microseconds for buffer %d\n",
               latency, toread_shwr_buf_num);
        cntrl_word = toread_shwr_buf_num;
        write_trig(SHWR_BUF_CONTROL_ADDR,cntrl_word);

        // Check status just after resetting full flag
        //status = read_trig(SHWR_BUF_STATUS_ADDR);
        //printf("Shower buf: After reset full flag\n");
        //printf("Shower buf status %x  writing %d  to read %d  full %x  num full=%d\n",
        //     status,SHWR_BUF_WNUM_MASK & (status >> SHWR_BUF_WNUM_SHIFT),
        //     SHWR_BUF_RNUM_MASK & (status >> SHWR_BUF_RNUM_SHIFT), 
        //     SHWR_BUF_FULL_MASK & (status >> SHWR_BUF_FULL_SHIFT),
        //     0x7 & (status >> SHWR_BUF_NFULL_SHIFT));
 
        //printf("Trigger_test: Full flag reset\n");
        //fflush(stdout);

        // Indicate data has been read
        full_shw_rd_bufs[readto_shw_buf_num] = 1;
        readto_shw_buf_num = (readto_shw_buf_num+1)%NUM_BUFFERS;
      }
#endif // TRIGGER_POLLED

    if (full_shw_rd_bufs[unpack_shw_buf_num] != 0)
      {
        unpack_shw_buffers(); // Unpack the buffers
        check_shw_buffers();  // Do sanity check of shower buffers
        print_shw_buffers();  // Print out the buffer
        // This needs to be last -- not sure why
        full_shw_rd_bufs[unpack_shw_buf_num] = 0;
        unpack_shw_buf_num = (unpack_shw_buf_num+1)%NUM_BUFFERS;
     }
 
#ifdef TRIGGER_POLLED
    // Is an interrupt pending?
    muon_status = read_trig(MUON_BUF_STATUS_ADDR);
    // printf("Checked muon buffer status\n");
    if ((MUON_INTR_PEND_MASK & (muon_status >> MUON_INTR_PEND_SHIFT)) != 0)
      {
        toread_muon_buf_num = MUON_BUF_RNUM_MASK & 
          (muon_status >> MUON_BUF_RNUM_SHIFT);
        cur_muon_buf_num = MUON_BUF_WNUM_MASK & 
          (muon_status >> MUON_BUF_WNUM_SHIFT);
        full_muon_bufs = MUON_BUF_FULL_MASK & 
          (muon_status >> MUON_BUF_FULL_SHIFT);
        num_full = 0x7 & (muon_status >> MUON_BUF_NFULL_SHIFT);
        printf("Muon buf writing %d  to read %d  full %x  num full=%d\n",
               cur_muon_buf_num,toread_muon_buf_num,
               full_muon_bufs,num_full);
 
        // Do readout of buffer here ....
        read_muon_buffers();  // Read buffers to local memory

        // Reset full flag
        // write_trig(MUON_BUF_CONTROL_ADDR,toread_muon_buf_num);

        // Check that full flags are cleared
        while (num_full != 0) {
          write_trig(MUON_BUF_CONTROL_ADDR,toread_muon_buf_num);
          muon_status = read_trig(MUON_BUF_STATUS_ADDR);
          toread_muon_buf_num = MUON_BUF_RNUM_MASK & 
            (muon_status >> MUON_BUF_RNUM_SHIFT);
          cur_muon_buf_num = MUON_BUF_WNUM_MASK & 
            (muon_status >> MUON_BUF_WNUM_SHIFT);
          full_muon_bufs = MUON_BUF_FULL_MASK & 
            (muon_status >> MUON_BUF_FULL_SHIFT);
          num_full = 0x7 & (muon_status >> MUON_BUF_NFULL_SHIFT);
          printf("Muon buf writing %d  to read %d  full %x  num full=%d\n",
                 cur_muon_buf_num,toread_muon_buf_num,
                 full_muon_bufs,num_full);
        }

        // Indicate data has been read
        Muon_Data_Read = 1;
      }
#endif // TRIGGER_POLLED

    if (Muon_Data_Read != 0)
      {
        unpack_muon_buffers(); // Unpack the buffers
        Muon_Data_Read = 0;
        check_muon_buffers();  // Do sanity check of shower buffers
        print_muon_buffers();  // Print out the buffer
      }
    fflush(stdout);  // Ensure event flushed to file
  }
  // Disable shower interrupts from the sde_trigger module. --
  // For test if disable after enable works
  // SDE_TRIGGER_EnableInterrupts((int *) SDE_SHWR_TRIGGER_INTR_BASE, 0);
  // SDE_TRIGGER_EnableInterrupts((int *) SDE_MUON_TRIGGER_INTR_BASE, 0);
}


#ifdef TRIGGER_INTERRUPT
void sde_shwr_intr_handler(void *CallbackRef)
{
  int cur_shwr_buf_num = 0;
  int full_shwr_bufs = 0;
  int cntrl_word = 0;
  int num_full;
  int num_used;
  int i;
  double ave_full;
  double ave_used;

  // Is an interrupt pending?  Should be if we get here.
  status = read_trig(SHWR_BUF_STATUS_ADDR);
  if ((SHWR_INTR_PEND_MASK & (status >> SHWR_INTR_PEND_SHIFT)) != 0)
    {
      toread_shwr_buf_num = SHWR_BUF_RNUM_MASK &
        (status >> SHWR_BUF_RNUM_SHIFT);
      cur_shwr_buf_num = SHWR_BUF_WNUM_MASK & (status >> SHWR_BUF_WNUM_SHIFT);
      full_shwr_bufs = SHWR_BUF_FULL_MASK & (status >> SHWR_BUF_FULL_SHIFT);
      num_full = 0x7 & (status >> SHWR_BUF_NFULL_SHIFT);
      ave_num_full += num_full;
      if (num_full > max_num_full) max_num_full = num_full;
#ifndef VERBOSE_BUFFERS
        if ((nevents+missed_events)%EVENT_COUNT_INTERVAL == 0)
        {
          ave_full = (double)ave_num_full/double(EVENT_COUNT_INTERVAL);
        	ave_num_full = 0;
                ave_used = (double)ave_num_used/double(EVENT_COUNT_INTERVAL);
                ave_num_used = 0;
            printf("Trigger_test: Shwr intr Rd %d Msd %d events",
                   nevents, missed_events);
            printf(" Ave/max full %f %d Ave/max used %f %d\n",
                   ave_full, max_num_full, ave_used, max_num_used);
            max_num_full = 0;
            max_num_used = 0;

            printf("Trigger_test: Counts - Compat SB %d  Compat ToT %d",
                   compat_sb_count, compat_tot_count);
            printf("  Compat ToTd %d  SB %d  EXT %d",
                   compat_totd_count, sb_count, compat_ext_count);
            printf("  Compat MoPS %d  Rndm %d",
                   compat_mops_count, rndm_count);
            printf("  Compat SB dlyd %d  Compat ToT dlyd %d",
                   compat_sb_dlyd_count, compat_tot_dlyd_count);
            printf("  Compat ToTd dlyd %d  SB dlyd %d  EXT dlyd %d",
                   compat_totd_dlyd_count, sb_dlyd_count, 
                   compat_ext_dlyd_count);
            printf("  Compat MoPS dlyd %d  Rndm dlyd %d\n",
                   compat_mops_dlyd_count, rndm_dlyd_count);

          compat_sb_count = 0;
          compat_tot_count = 0;
          compat_totd_count = 0;
          compat_mops_count = 0;
          sb_count = 0;
          rndm_count = 0;
          compat_ext_count = 0;
          compat_sb_dlyd_count = 0;
          compat_tot_dlyd_count = 0;
          compat_totd_dlyd_count = 0;
          compat_mops_dlyd_count = 0;
          sb_dlyd_count = 0;
          rndm_dlyd_count = 0;
          compat_ext_dlyd_count = 0;
        }
        if (toread_shwr_buf_num != ((prev_read+1) & 0x3))
          {
            printf("Shwr intr writing %d  to read %d  full %x  num full=%d",
                   cur_shwr_buf_num,toread_shwr_buf_num,
                   full_shwr_bufs,num_full);
            printf(" ******** ERROR ******* (check scope not running)");
            printf("\n");  
            exit(1);
          }
#endif
#ifdef VERBOSE_BUFFERS
        printf("Shwr intr writing %d  to read %d  full %x  num full=%d",
               cur_shwr_buf_num,toread_shwr_buf_num,
               full_shwr_bufs,num_full);
        if (toread_shwr_buf_num != ((prev_read+1) & 0x3))
          {
            printf(" ******** ERROR ******* (check scope not running)");
            printf("\n");
            exit(1);
          }
        printf("\n");
#endif
        prev_read = toread_shwr_buf_num;

        // Keep track of local memory usage
        num_used = 0;
        for (i=0; i<NUM_BUFFERS; i++)
          num_used += full_shw_rd_bufs[i];
        ave_num_used += num_used;
        if (num_used > max_num_used) max_num_used = num_used;
 
        // If room, read buffers to local memory
        if (full_shw_rd_bufs[readto_shw_buf_num] == 0)
          {
            read_shw_buffers();
            nevents++;
            // Indicate buffer available using a shared variable
            full_shw_rd_bufs[readto_shw_buf_num] = 1;
            readto_shw_buf_num = (readto_shw_buf_num+1)%NUM_BUFFERS;
              /* printf("Trigger_test: readto_buf=%2d upack_buf=%2d num_used=%2d",  */
              /*        readto_shw_buf_num, unpack_shw_buf_num, num_used); */
              /* for (i=0; i<NUM_BUFFERS; i++) */
              /*   printf(" %2d", full_shw_rd_bufs[i]); */
              /* printf("\n"); */
          }
        else
          {
          missed_events++;
          if (num_used != NUM_BUFFERS)
            {
              printf("Buf. manag. error: readto_buf=%2d num_used=%2d", 
                     readto_shw_buf_num, num_used);
              for (i=0; i<NUM_BUFFERS; i++)
                printf(" %2d", full_shw_rd_bufs[i]);
              printf("\n");
            }
          }

      // Reset full flag
      cntrl_word = toread_shwr_buf_num;
      write_trig(SHWR_BUF_CONTROL_ADDR,cntrl_word);
    }

  // Acknowledge the trigger to allow further interrupts
  SDE_TRIGGER_ACK((int *) SDE_SHWR_TRIGGER_INTR_BASE, 1);

}

void sde_muon_intr_handler(void *CallbackRef)
{
  int cur_muon_buf_num = 0;
  int full_muon_bufs = 0;
  int cntrl_word = 0;
  int num_full;



  // Is an interrupt pending?  Should be if we get here.
  status = read_trig(MUON_BUF_STATUS_ADDR);
  if ((MUON_INTR_PEND_MASK & (status >> MUON_INTR_PEND_SHIFT)) != 0)
    {
      toread_muon_buf_num = MUON_BUF_RNUM_MASK &
        (status >> MUON_BUF_RNUM_SHIFT);
      cur_muon_buf_num = MUON_BUF_WNUM_MASK & (status >> MUON_BUF_WNUM_SHIFT);
      full_muon_bufs = MUON_BUF_FULL_MASK & (status >> MUON_BUF_FULL_SHIFT);
      num_full = 0x7 & (status >> MUON_BUF_NFULL_SHIFT);
      printf("trigger_test: Muon intr writing %d  to read %d  full %x  num full=%d\n",
             cur_muon_buf_num,toread_muon_buf_num,full_muon_bufs,num_full);

      // If room, read buffers to local memory
      if (Muon_Data_Read == 0) 
        read_muon_buffers();
      else
        printf("trigger_test: Local memory buffer not free\n");

      // Reset full flag
      cntrl_word = toread_muon_buf_num;
      write_trig(MUON_BUF_CONTROL_ADDR,cntrl_word);
    }
  // Indicate the interrupt has been processed using a shared variable
  Muon_Data_Read = 1;

  // Acknowledge the trigger to allow further interrupts
  SDE_TRIGGER_ACK((int *) SDE_MUON_TRIGGER_INTR_BASE, 1);
}
#endif  // TRIGGER_INTERRUPT

 void enable_trigger_intr()
 {
#ifdef TRIGGER_INTERRUPT
   // Enable the interrupt from the trigger at the interrupt controller
   // For now do both shower and muon enable together
  XScuGic_Enable(&IntController,
		 XPAR_FABRIC_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_SHWR_IRQ_INTR); 
  XScuGic_Enable(&IntController,
		 XPAR_FABRIC_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_MUON_IRQ_INTR); 
#endif  //TRIGGER_INTERRUPT
 }

 void disable_trigger_intr()
 {
#ifdef TRIGGER_INTERRUPT
   // Disable the interrupt from the trigger at the interrupt controller
   // For now do both shower and muon disable together
  XScuGic_Disable(&IntController,
		 XPAR_FABRIC_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_SHWR_IRQ_INTR); 
  XScuGic_Disable(&IntController,
		 XPAR_FABRIC_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_MUON_IRQ_INTR); 
#endif  //TRIGGER_INTERRUPT
 }
