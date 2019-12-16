
// Simple standalone test routine to interact with the sde_trigger PL.
//
// 26-Feb-2016 DFN Initial (reconstructed from lost code) version
//                 The initial version does not test interrupts - 
//                 to be restored later
// 11-Apr-2016 DFN Add simple polled DMA
// 29-Apr-2016 DFN Implement TRIGGER_INTERRUPT
// 30-Apr-2018 DFN Implement split shower & muon interrupts
// 04-Nov-2019 DFN Add MoPS and Random triggers

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

/* #ifdef DMA */
/* static XAxiCdma AxiCdmaInstance0;	// Instance of the XAxiCdma 0 */
/* static  XAxiCdma_Config *DmaCfgPtr0; */
/* static XAxiCdma AxiCdmaInstance1;	// Instance of the XAxiCdma 1 */
/* static  XAxiCdma_Config *DmaCfgPtr1; */
/* #endif */

#ifdef TRIGGER_INTERRUPT
static XScuGic IntController;	// Instance of the Interrupt Controller
static XScuGic_Config *IntCfgPtr;  // The config. parameters of the controller
#endif

volatile static int Shwr_DMA_Error = 0;	/* Dma Error occurs */
volatile static int Muon_DMA_Error = 0;	/* Dma Error occurs */
volatile static int Shwr_Data_Read = 0;
volatile static int Muon_Data_Read = 0;
volatile static int Shwr_DMA_Done = 0;
volatile static int Muon_DMA_Done = 0;
volatile static int prev_read = -1;
volatile static int ave_num_full = 0;
volatile static int ave_num_used = 0;
volatile static int max_num_full = 0;
volatile static int max_num_used = 0;

#ifdef SCATTER_GATHER
XAxiCdma_Bd ShwrBdTemplate;
XAxiCdma_Bd *ShwrBdPtr;
XAxiCdma_Bd *ShwrBdCurPtr;
int ShwrBdCount;
u8 *ShwrSrcBufferPtr;
int ShwrIndex;
XAxiCdma_Bd MuonBdTemplate;
XAxiCdma_Bd *MuonBdPtr;
XAxiCdma_Bd *MuonBdCurPtr;
int MuonBdCount;
u8 *MuonSrcBufferPtr;
int MuonIndex;

// bd_space should be an exact multiple of BD size for both shower & muon
// buffer transfers, and should be aligned on 64 byte boundary.  
#define ONE_BD_LEN 16
#define SHWR_BD_SPACE_LEN ONE_BD_LEN*NUM_SHWR_BDS_TO_TRANSFER*10
#define MUON_BD_SPACE_LEN ONE_BD_LEN*NUM_MUON_BDS_TO_TRANSFER*10
u32 shwr_bd_space[SHWR_BD_SPACE_LEN] __attribute__((aligned(128)));
u32 muon_bd_space[MUON_BD_SPACE_LEN] __attribute__((aligned(128)));
#endif

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

 /* #ifdef DMA */
/*   // Initialize the XAxiCdma device. */
/*   DmaCfgPtr0 = XAxiCdma_LookupConfig(XPAR_ZYNC_BLOCK_AXI_CDMA_0_DEVICE_ID); */
/*   if (status != XST_SUCCESS) */
/*     { */
/*       printf("trigger_test: Failed to lookup XAxiCdma device 0.\n"); */
/*       return; */
/*     } */
/*   // Initialize the XAxiCdma device. */
/*   DmaCfgPtr1 = XAxiCdma_LookupConfig(XPAR_ZYNC_BLOCK_AXI_CDMA_1_DEVICE_ID); */
/*   if (status != XST_SUCCESS) */
/*     { */
/*       printf("trigger_test: Failed to lookup XAxiCdma device 1.\n"); */
/*       return; */
/*     } */
  
/*   status = XAxiCdma_CfgInitialize(&AxiCdmaInstance0, DmaCfgPtr0, */
/*                                   DmaCfgPtr0->BaseAddress); */
/*   if (status != XST_SUCCESS)  */
/*     { */
/*       printf("trigger_test: Failed to initialize XAxiCdma device0.\n"); */
/*       return; */
/*     } */

/*   status = XAxiCdma_CfgInitialize(&AxiCdmaInstance1, DmaCfgPtr1, */
/*                                   DmaCfgPtr1->BaseAddress); */
/*   if (status != XST_SUCCESS)  */
/*     { */
/*       printf("trigger_test: Failed to initialize XAxiCdma device 1.\n"); */
/*       return; */
/*     } */

/* #ifdef SCATTER_GATHER */
/*   // Set up BD rings */
/*   ShwrBdCount = XAxiCdma_BdRingCntCalc(XAXICDMA_BD_MINIMUM_ALIGNMENT, */
/*                                        sizeof(shwr_bd_space), */
/*                                        (unsigned int) shwr_bd_space); */

/*   status = XAxiCdma_BdRingCreate(&AxiCdmaInstance0,  */
/*                                  (unsigned int) shwr_bd_space, */
/*                                  (unsigned int) shwr_bd_space, */
/*                                  XAXICDMA_BD_MINIMUM_ALIGNMENT, ShwrBdCount); */
/*   if (status != XST_SUCCESS) { */
/*     printf("trigger_test: Create Shwr BD ring failed %d\r\n",status); */
/*     return; */
/*   } */

/*   MuonBdCount = XAxiCdma_BdRingCntCalc(XAXICDMA_BD_MINIMUM_ALIGNMENT, */
/*                                        sizeof(muon_bd_space), */
/*                                        (unsigned int) muon_bd_space); */

/*   status = XAxiCdma_BdRingCreate(&AxiCdmaInstance1,  */
/*                                  (unsigned int) muon_bd_space, */
/*                                  (unsigned int) muon_bd_space, */
/*                                  XAXICDMA_BD_MINIMUM_ALIGNMENT, MuonBdCount); */
/*   if (status != XST_SUCCESS) { */
/*     printf("trigger_test: Create Muon BD ring failed %d\r\n",status); */
/*     return; */
/*   } */

/*   // Setup a BD templates to copy to every BD. */
/*   XAxiCdma_BdClear(&ShwrBdTemplate); */
/*   status = XAxiCdma_BdRingClone(&AxiCdmaInstance0, &ShwrBdTemplate); */
/*   if (status != XST_SUCCESS) { */
/*     printf("trigger_test: Clone Shwr BD ring failed %d\r\n",status); */
/*     return; */
/*   } */
/*   XAxiCdma_BdClear(&MuonBdTemplate); */
/*   status = XAxiCdma_BdRingClone(&AxiCdmaInstance1, &MuonBdTemplate); */
/*   if (status != XST_SUCCESS) { */
/*     printf("trigger_test: Clone Muon BD ring failed %d\r\n",status); */
/*     return; */
/*   } */
/* #endif */

/*   // Set up interrupt system */
/* #ifndef DMA_INTERRUPT */
/*   // Disable DMA interrupts, we use polling mode for DMA completion */
/*   XAxiCdma_IntrDisable(&AxiCdmaInstance0, XAXICDMA_XR_IRQ_ALL_MASK); */
/*   XAxiCdma_IntrDisable(&AxiCdmaInstance1, XAXICDMA_XR_IRQ_ALL_MASK); */
/* #endif */
/* #endif  //DMA */

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


/* #if defined(SIMPLE) && defined(DMA) */
/* int do_simple_polled_shwr_dma(u32 *SrcPtr, u32 *DestPtr, int length) */
/* { */
/*   status =  */
/*     XAxiCdma_SimpleTransfer(&AxiCdmaInstance0, (int) SrcPtr, */
/*                             (int) DestPtr, length, NULL, NULL); */
/*   if (status != XST_SUCCESS) return XST_FAILURE; */

/*   // Wait until the DMA transfer is done */
/*   while (XAxiCdma_IsBusy(&AxiCdmaInstance0)); */

/*   // If the hardware has errors, this example fails */
/*   // This is a poll example, no interrupt handler is involved. */
/*   // Therefore, error conditions are not cleared by the driver. */
/*   int Shwr_DMA_Error = XAxiCdma_GetError(&AxiCdmaInstance0); */
/*   if (Shwr_DMA_Error != 0x0) { */
/*     printf("trigger_test: AXI shwr DMA error\n"); */
/*     return XST_FAILURE; */
/*   } */

/*   // Invalidate the DestBuffer before receiving the data, in case the */
/*   // Data Cache is enabled */
/*   Xil_DCacheInvalidateRange((int) DestPtr, length);		 */

/*   return XST_SUCCESS; */
/* } */

/* int do_simple_polled_muon_dma(u32 *SrcPtr, u32 *DestPtr, int length) */
/* { */
/*   status =  */
/*     XAxiCdma_SimpleTransfer(&AxiCdmaInstance1, (int) SrcPtr, */
/*                             (int) DestPtr, length, NULL, NULL); */
/*   if (status != XST_SUCCESS) return XST_FAILURE; */

/*   // Wait until the DMA transfer is done */
/*   while (XAxiCdma_IsBusy(&AxiCdmaInstance1)); */

/*   // If the hardware has errors, this example fails */
/*   // This is a poll example, no interrupt handler is involved. */
/*   // Therefore, error conditions are not cleared by the driver. */
/*   int Muon_DMA_Error = XAxiCdma_GetError(&AxiCdmaInstance1); */
/*   if (Muon_DMA_Error != 0x0) { */
/*     printf("trigger_test: AXI muon DMA error\n"); */
/*     return XST_FAILURE; */
/*   } */

/*   // Invalidate the DestBuffer before receiving the data, in case the */
/*   // Data Cache is enabled */
/*   Xil_DCacheInvalidateRange((int) DestPtr, length);		 */

/*   return XST_SUCCESS; */
/* } */
/* #endif */

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

/* #ifdef SCATTER_GATHER */
/* int check_shwr_scatter_gather_completion() */
/* { */
/*   int BdCount; */

/*   /\* Check whether the hardware has encountered any problems. */
/*    * In some error cases, the DMA engine may not able to update the */
/*    * BD that has caused the problem. */
/*    *\/ */
/*   if (XAxiCdma_GetError(&AxiCdmaInstance0) != 0x0) { */
/*     printf("trigger_test: Transfer error %x\r\n", */
/*            (unsigned int)XAxiCdma_GetError(&AxiCdmaInstance0)); */
/*     Shwr_DMA_Error = 1; */
/*     return 0; */
/*   } */

/*   // Get all processed BDs from hardware */
/*   BdCount = XAxiCdma_BdRingFromHw(&AxiCdmaInstance0, XAXICDMA_ALL_BDS,  */
/*                                   &ShwrBdPtr); */

/*   // Check finished BDs then release them */
/*   if(BdCount > 0) { */
/*     ShwrBdCurPtr = ShwrBdPtr; */
/*     for (ShwrIndex = 0; ShwrIndex < BdCount; ShwrIndex++) { */
/*       // If the completed BD has error bit set, */
/*       // then the example fails */
/*       if (XAxiCdma_BdGetSts(ShwrBdCurPtr) & */
/*           XAXICDMA_BD_STS_ALL_ERR_MASK)	{ */
/*         printf("trigger_test: BD error bit set\n"); */
/*         Shwr_DMA_Error = 1; */
/*         return 0; */
/*       } */

/*       ShwrBdCurPtr = XAxiCdma_BdRingNext(&AxiCdmaInstance0, ShwrBdCurPtr); */
/*     } */

/*     // Release the BDs so later submission can use them */
/*     //    printf("trigger_test: Releasing BDs, BdCount=%d\n", BdCount); */
/*     status = XAxiCdma_BdRingFree(&AxiCdmaInstance0, BdCount, ShwrBdPtr); */
/*     if(status != XST_SUCCESS) { */
/*       printf("trigger_test: Error free BD %x\r\n", status); */
/*       Shwr_DMA_Error = 1; */
/*       return 0; */
/*     } */
/*     Shwr_DMA_Done += BdCount; */
/*   } */
/*   return Shwr_DMA_Done; */
/* } */
/* int check_muon_scatter_gather_completion() */
/* { */
/*   int BdCount; */

/*   /\* Check whether the hardware has encountered any problems. */
/*    * In some error cases, the DMA engine may not able to update the */
/*    * BD that has caused the problem. */
/*    *\/ */
/*   if (XAxiCdma_GetError(&AxiCdmaInstance1) != 0x0) { */
/*     printf("trigger_test: Transfer error %x\r\n", */
/*            (unsigned int)XAxiCdma_GetError(&AxiCdmaInstance1)); */
/*     Muon_DMA_Error = 1; */
/*     return 0; */
/*   } */

/*   // Get all processed BDs from hardware */
/*   BdCount = XAxiCdma_BdRingFromHw(&AxiCdmaInstance1, XAXICDMA_ALL_BDS,  */
/*                                   &MuonBdPtr); */

/*   // Check finished BDs then release them */
/*   if(BdCount > 0) { */
/*     MuonBdCurPtr = MuonBdPtr; */
/*     for (MuonIndex = 0; MuonIndex < BdCount; MuonIndex++) { */
/*       // If the completed BD has error bit set, */
/*       // then the example fails */
/*       if (XAxiCdma_BdGetSts(MuonBdCurPtr) & */
/*           XAXICDMA_BD_STS_ALL_ERR_MASK)	{ */
/*         printf("trigger_test: BD error bit set\n"); */
/*         Muon_DMA_Error = 1; */
/*         return 0; */
/*       } */

/*       MuonBdCurPtr = XAxiCdma_BdRingNext(&AxiCdmaInstance1, MuonBdCurPtr); */
/*     } */

/*     // Release the BDs so later submission can use them */
/*     //    printf("trigger_test: Releasing BDs, BdCount=%d\n", BdCount); */
/*     status = XAxiCdma_BdRingFree(&AxiCdmaInstance1, BdCount, MuonBdPtr); */
/*     if(status != XST_SUCCESS) { */
/*       printf("trigger_test: Error free BD %x\r\n", status); */
/*       Muon_DMA_Error = 1; */
/*       return 0; */
/*     } */
/*     Muon_DMA_Done += BdCount; */
/*   } */
/*   return Muon_DMA_Done; */
/* } */

/* int do_scatter_gather_polled_shwr_dma() */
/* { */
/*   status = XAxiCdma_BdRingAlloc(&AxiCdmaInstance0, */
/*                                 NUM_SHWR_BDS_TO_TRANSFER, &ShwrBdPtr); */
/*   if (status != XST_SUCCESS) { */
/*     printf("trigger_test: Failed shwr bd alloc\r\n"); */
/*     return XST_FAILURE; */
/*   } */
/*   ShwrBdCurPtr = ShwrBdPtr; */

/*   // Set up the BDs */

/*   // Shower buffer 0 */
/*   mem_addr = (u32*) TRIGGER_MEMORY_SHWR0_BASE; */
/*   mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS; */
/*   status = XAxiCdma_BdSetSrcBufAddr(ShwrBdCurPtr, (unsigned int) mem_addr); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set shwr src addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)mem_addr); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetDstBufAddr(ShwrBdCurPtr, (unsigned int)  */
/*                                     &shw_mem0[readto_shw_buf_num][0]); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set shwr dst addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)shw_mem0); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetLength(ShwrBdCurPtr, 4*SHWR_MEM_WORDS); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set shwr BD length failed %d\r\n", status); */
/*     return XST_FAILURE; */
/*   } */
/*   ShwrBdCurPtr = XAxiCdma_BdRingNext(&AxiCdmaInstance0, ShwrBdCurPtr); */

/*   // Shower buffer 1 */
/*   mem_addr = (u32*) TRIGGER_MEMORY_SHWR1_BASE; */
/*   mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS; */
/*   status = XAxiCdma_BdSetSrcBufAddr(ShwrBdCurPtr, (unsigned int) mem_addr); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set shwr src addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)mem_addr); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetDstBufAddr(ShwrBdCurPtr, (unsigned int)  */
/*                                     &shw_mem1[readto_shw_buf_num][0]); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set dst addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)shw_mem1); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetLength(ShwrBdCurPtr, 4*SHWR_MEM_WORDS); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set BD length failed %d\r\n", status); */
/*     return XST_FAILURE; */
/*   } */
/*   ShwrBdCurPtr = XAxiCdma_BdRingNext(&AxiCdmaInstance0, ShwrBdCurPtr); */

/*   // Shower buffer 2 */
/*   mem_addr = (u32*) TRIGGER_MEMORY_SHWR2_BASE; */
/*   mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS; */
/*   status = XAxiCdma_BdSetSrcBufAddr(ShwrBdCurPtr, (unsigned int) mem_addr); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set src addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)mem_addr); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetDstBufAddr(ShwrBdCurPtr, (unsigned int)  */
/*                                     &shw_mem2[readto_shw_buf_num][0]); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set dst addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)shw_mem2); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetLength(ShwrBdCurPtr, 4*SHWR_MEM_WORDS); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set BD length failed %d\r\n", status); */
/*     return XST_FAILURE; */
/*   } */
/*   ShwrBdCurPtr = XAxiCdma_BdRingNext(&AxiCdmaInstance0, ShwrBdCurPtr); */

/*   // Shower buffer 3 */
/*   mem_addr = (u32*) TRIGGER_MEMORY_SHWR3_BASE; */
/*   mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS; */
/*   status = XAxiCdma_BdSetSrcBufAddr(ShwrBdCurPtr, (unsigned int) mem_addr); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set src addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)mem_addr); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetDstBufAddr(ShwrBdCurPtr, (unsigned int)  */
/*                                     &shw_mem3[readto_shw_buf_num][0]); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set dst addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)shw_mem3); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetLength(ShwrBdCurPtr, 4*SHWR_MEM_WORDS); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set BD length failed %d\r\n", status); */
/*     return XST_FAILURE; */
/*   } */
/*   ShwrBdCurPtr = XAxiCdma_BdRingNext(&AxiCdmaInstance0, ShwrBdCurPtr); */

/*   // Shower buffer 4 */
/*   mem_addr = (u32*) TRIGGER_MEMORY_SHWR4_BASE; */
/*   mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS; */
/*   status = XAxiCdma_BdSetSrcBufAddr(ShwrBdCurPtr, (unsigned int) mem_addr); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set src addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)mem_addr); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetDstBufAddr(ShwrBdCurPtr, (unsigned int)  */
/*                                     &shw_mem4[readto_shw_buf_num]); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set dst addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)ShwrBdCurPtr, */
/*            (unsigned int)shw_mem4); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetLength(ShwrBdCurPtr, 4*SHWR_MEM_WORDS); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set BD length failed %d\r\n", status); */
/*     return XST_FAILURE; */
/*   } */

/*   // Give the BDs to hardware */
/*   status = XAxiCdma_BdRingToHw(&AxiCdmaInstance0, NUM_SHWR_BDS_TO_TRANSFER, */
/*                                ShwrBdPtr, NULL, NULL); */
/*   if (status != XST_SUCCESS) { */
/*     printf("trigger_test: Failed to give BDs to hw %d\r\n", status); */
/*     return XST_FAILURE; */
/*   }  */
/*   //  else */
/*   //  printf("trigger_test: Scatter gather DMA started\n");  */

/*   // Wait until the DMA transfer is done or error occurs */
/*   Shwr_DMA_Done = 0; */
/*   while ((check_shwr_scatter_gather_completion() < NUM_SHWR_BDS_TO_TRANSFER) */
/*          && !Shwr_DMA_Error) { */
/*     /\* Wait *\/ */
/*   } */
/*   AxiCdmaInstance0.SgHandlerHead = AxiCdmaInstance0.SgHandlerTail;  */

/*   if (Shwr_DMA_Error) { */
/*     printf("trigger_test: Transfer has error %x\r\n", */
/*            Shwr_DMA_Error); */
/*     return XST_FAILURE; */
/*   } else { */
/*     //    printf("trigger_test: Scatter gather DMA completed\n"); */
/*     return XST_SUCCESS; */
/*   } */
/* } */

/* int do_scatter_gather_polled_muon_dma() */
/* { */
/*   status = XAxiCdma_BdRingAlloc(&AxiCdmaInstance1,  */
/*                                 NUM_MUON_BDS_TO_TRANSFER, &MuonBdPtr); */
/*   if (status != XST_SUCCESS) { */
/*     printf("trigger_test: Failed muon bd alloc\r\n"); */
/*     return XST_FAILURE; */
/*   } */
/*   MuonBdCurPtr = MuonBdPtr; */

/*   // Set up the BDs */

/*   // Muon buffer 0 */
/*   mem_addr = (u32*) TRIGGER_MEMORY_MUON0_BASE; */
/*   mem_addr = mem_addr + toread_muon_buf_num * MUON_MEM_WORDS; */
/*   status = XAxiCdma_BdSetSrcBufAddr(MuonBdCurPtr, (unsigned int) mem_addr); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set muon src addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)MuonBdCurPtr, */
/*            (unsigned int)mem_addr); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetDstBufAddr(MuonBdCurPtr, (unsigned int) muon_mem0); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set muon dst addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)MuonBdCurPtr, */
/*            (unsigned int)muon_mem0); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetLength(MuonBdCurPtr, 4*MUON_MEM_WORDS); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set muon BD length failed %d\r\n", status); */
/*     return XST_FAILURE; */
/*   } */
/*   MuonBdCurPtr = XAxiCdma_BdRingNext(&AxiCdmaInstance1, MuonBdCurPtr); */

/*   // Muon buffer 1 */
/*   mem_addr = (u32*) TRIGGER_MEMORY_MUON1_BASE; */
/*   mem_addr = mem_addr + toread_muon_buf_num * MUON_MEM_WORDS; */
/*   status = XAxiCdma_BdSetSrcBufAddr(MuonBdCurPtr, (unsigned int) mem_addr); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set muon src addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)MuonBdCurPtr, */
/*            (unsigned int)mem_addr); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetDstBufAddr(MuonBdCurPtr, (unsigned int) muon_mem1); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set muon dst addr failed %d, %x/%x\r\n", */
/*            status, (unsigned int)MuonBdCurPtr, */
/*            (unsigned int)muon_mem1); */
/*     return XST_FAILURE; */
/*   } */
/*   status = XAxiCdma_BdSetLength(MuonBdCurPtr, 4*MUON_MEM_WORDS); */
/*   if(status != XST_SUCCESS) { */
/*     printf("trigger_test: Set muon BD length failed %d\r\n", status); */
/*     return XST_FAILURE; */
/*   } */
/*   MuonBdCurPtr = XAxiCdma_BdRingNext(&AxiCdmaInstance1, MuonBdCurPtr); */

/*   // Give the BDs to hardware */
/*   status = XAxiCdma_BdRingToHw(&AxiCdmaInstance1,  */
/*                                NUM_MUON_BDS_TO_TRANSFER, MuonBdPtr, NULL, NULL); */
/*   if (status != XST_SUCCESS) { */
/*     printf("trigger_test: Failed to give muon BDs to hw %d\r\n", status); */
/*     return XST_FAILURE; */
/*   }  */
/*   //else */
/*   //  printf("trigger_test: Scatter gather muon DMA started\n"); */

/*   // Wait until the DMA transfer is done or error occurs */
/*   Muon_DMA_Done = 0; */
/*   while ((check_muon_scatter_gather_completion() < NUM_MUON_BDS_TO_TRANSFER) */
/*          && !Muon_DMA_Error) { */
/*     /\* Wait *\/ */
/*   } */
/*   AxiCdmaInstance1.SgHandlerHead = AxiCdmaInstance1.SgHandlerTail;  */

/*   if (Muon_DMA_Error) { */
/*     printf("trigger_test: Muon buffer transfer has error %x\r\n", */
/*            Muon_DMA_Error); */
/*     return XST_FAILURE; */
/*   } else { */
/*     printf("trigger_test: Muon buffer scatter gather DMA completed\n"); */
/*     return XST_SUCCESS; */
/*   } */
/* } */
/* #endif */

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
