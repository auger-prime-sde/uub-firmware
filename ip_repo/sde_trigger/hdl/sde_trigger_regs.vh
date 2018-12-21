// sde_trigger_regs.vh
// 
// This is the register definition portion of the sde_trigger that is
// included into the base sde_trigger_vM_N_S00_AXI.v AXI peripheral
// generated by Vivado.  This keeps the guts of our trigger code
// separated from all the AXI register interface code.
// 
// 22-Nov-2016 DFN Initial version split off from sde_trigger_code.vh because
//                 that file was getting too large.
// 21-Nov-2017 DFN Add temporary EVT_ID registers to keep unique version for
//                 each shower buffer
// 16-May-2018 DFN Add registers to keep track of compatibility ToT triggers

// Shower buffer handling registers
reg [`SHWR_TRIG_DLY:0] SHWR_TRIG_DLYD; // Trigger delayed to end of buf
reg [`SHWR_DEAD_DLY:0] SHWR_DEAD_DLYD; // Dead time after end of buf

reg [`SHWR_MEM_NBUF-1:0] SHWR_BUF_RESET;
reg [`SHWR_BUF_NUM_WIDTH:0] SHWR_BUF_NUM_FULL;
reg [`SHWR_MEM_ADDR_WIDTH-1:0] SHWR_ADDR1;
reg [`SHWR_MEM_NBUF-1:0] SHWR_BUF_FULL_FLAGS;
wire [31:0] LCL_SHWR_BUF_CONTROL;
reg [31:0] LCL_SHWR_BUF_START;
reg [31:0] LCL_SHWR_BUF_STARTT;
reg [`SHWR_MEM_BUF_SHIFT+
     `SHWR_BUF_NUM_WIDTH-1:0] LCL_SHWR_BUF_STARTN[0:`SHWR_MEM_NBUF-1];
reg [`SHWR_BUF_NUM_WIDTH-1:0] LCL_SHWR_BUF_WNUM;
reg [`SHWR_BUF_NUM_WIDTH-1:0] TMP_SHWR_BUF_WNUM;
reg [31:0] LCL_SHWR_BUF_STATUS;
reg [31:0] LCL_SHWR_BUF_TRIG_ID;
reg [31:0] LCL_SHWR_BUF_TRIG_IDN[0:`SHWR_MEM_NBUF-1];
reg [`SHWR_EVT_ID_WIDTH-1:0] LCL_SHWR_EVT_IDN[0:`SHWR_MEM_NBUF-1];
//wire [31:0] LCL_COMPATIBILITY_GLOBAL_CONTROL;
wire LCL_COMPATIBILITY_GLOBAL_CONTROL;

// AXI interface registers
reg AXI_REG_WRITE;
reg AXI_SHWR_CONTROL_WRITTEN;
reg AXI_MUON_CONTROL_WRITTEN;
wire LCL_SHWR_CONTROL_WRITTEN;
reg  PREV_SHWR_CONTROL_WRITTEN;

// ADC handling registers
reg [3:0] ADC_EXTRA;
reg [`ADC_WIDTH-1:0] FILTB_PMT0, FILTB_PMT1, FILTB_PMT2;
`ifdef KEEP_FILTD
reg [`ADC_WIDTH+1:0] FILTD_PMT0, FILTD_PMT1, FILTD_PMT2;
`endif
reg [2*`ADC_WIDTH-1:0] 		  ADC0_DLY[0:`ADC_FILT_DELAY];
reg [2*`ADC_WIDTH-1:0] 		  ADC1_DLY[0:`ADC_FILT_DELAY];
reg [2*`ADC_WIDTH-1:0] 		  ADC2_DLY[0:`ADC_FILT_DELAY];
reg [2*`ADC_WIDTH-1:0] 		  ADC3_DLY[0:`ADC_FILT_DELAY];
reg [2*`ADC_WIDTH-1:0] 		  ADC4_DLY[0:`ADC_FILT_DELAY];
reg [2*`ADC_WIDTH-1:0] 		  ADCD0;
reg [2*`ADC_WIDTH-1:0] 		  ADCD1;
reg [2*`ADC_WIDTH-1:0] 		  ADCD2;
reg [2*`ADC_WIDTH-1:0] 		  ADCD3;
reg [2*`ADC_WIDTH-1:0] 		  ADCD4;

// Registers for area & peak calculation
reg [`ADC_WIDTH-1:0] ADCD[0:9];
wire [`ADC_WIDTH-1:0] ADCDR[0:9];
wire [`SHWR_AREA_WIDTH-1:0] AREA[0:9];
wire [`ADC_WIDTH+`SHWR_BASELINE_EXTRA_BITS-1:0] BASELINE[0:9];
wire [`ADC_WIDTH+`SHWR_BASELINE_EXTRA_BITS-1:0] SBASELINE[0:9];
wire [`ADC_WIDTH-1:0] PEAK[0:9];
wire SATURATED[0:9];
reg [31:0] LCL_SHWR_PEAK_AREA0[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_PEAK_AREA1[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_PEAK_AREA2[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_PEAK_AREA3[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_PEAK_AREA4[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_PEAK_AREA5[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_PEAK_AREA6[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_PEAK_AREA7[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_PEAK_AREA8[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_PEAK_AREA9[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_BASELINE0[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_BASELINE1[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_BASELINE2[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_BASELINE3[0:`SHWR_MEM_NBUF-1];
reg [31:0] LCL_SHWR_BASELINE4[0:`SHWR_MEM_NBUF-1];

// Register for muon triggers & buffers
reg [`MUON_NUM_TRIGS-1:0] MUON_PRETRIG;
reg [`MUON_EXT_TRIG_DELAY:0] MUON_EXT_TRIG;
wire MUON_PRETRIG1, MUON_PRETRIG2, MUON_PRETRIG3, MUON_PRETRIG4;
wire [4:0] MUON1_DEBUG, MUON2_DEBUG, MUON3_DEBUG, MUON4_DEBUG;
wire [4:0] MUON_BUFFER_DEBUG;

// Registers for led controller
wire [4:0] LED_DEBUG;
wire [4:0] SB_TRIG_DEBUG;
wire LED_TRG_FLAG;
wire [31:0] LCL_LED_CONTROL;

// Trigger registers
reg TRIGGERED, SOME_TRIG_OR;
reg [31:0] SOME_TRIG;
reg [31:0] SOME_DLYD_TRIG;
reg [7:0] COMPAT_SB_TRIG_COUNTER;
reg [7:0] COMPAT_EXT_TRIG_COUNTER;
reg [7:0] COMPAT_TOT_TRIG_COUNTER;
reg [7:0] COMPAT_TOTD_TRIG_COUNTER;
reg PRESCALED_COMPAT_SB_TRIG;
reg PRESCALED_COMPAT_EXT_TRIG;
reg PRESCALED_COMPAT_TOT_TRIG;
reg PRESCALED_COMPAT_TOTD_TRIG;
wire STRETCHED_COMPAT_SB_TRIG;
wire STRETCHED_COMPAT_EXT_TRIG;
wire STRETCHED_COMPAT_TOT_TRIG;
wire STRETCHED_COMPAT_TOTD_TRIG;
wire TRIG_IN_SYNCED;
reg TRIG_IN_PREV;
reg EXT_TRIG;
reg [1:0] ENABLE40;
wire COMPATIBILITY_SB_TRIG;
wire COMPATIBILITY_TOT_TRIG;
wire COMPATIBILITY_TOTD_TRIG;
wire SB_TRIG;
wire STRETCHED_SB_TRIG;
wire COMPATIBILITY_TOT_DEBUG;
wire [59:0] COMPATIBILITY_TOTD_DEBUG;

// Other registers
reg LCL_RESET;

// Integers for loops
integer INDEX;
integer DELAY;
integer DEADDLY;
integer MUON_EXTDLY;
integer DLY_IDX;

