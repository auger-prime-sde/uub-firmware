// Bit and register definitions for test_control module
//
// 13-Feb-2019 DFN Initial version to improve documentation
// 09-Mar-2019 DFN Add option to generate pattern of pulses out TRIG_OUT rather
//                 than a single pulse.

`define USE_FAKE_ADDR 0
 `define USE_FAKE_PPS_BIT 0
 `define USE_FAKE_SHWR_BIT 1
 `define USE_FAKE_MUON_BIT 2
 `define USE_FAKE_RD_BIT 3
 `define USE_FAKE_RDCLK_BIT 4
 `define DISABLE_TRIG_OUT_BIT 5
 `define GENERATE_TRIG_OUT_BIT 6
 `define TRIG_OUT_PATTERN_BIT 7
 `define PATTERN_LEN 241
 `define PATTERN_0 0
 `define PATTERN_1 60
 `define PATTERN_2 120
 `define PATTERN_3 180
 `define NUM_PATTERNS 4

 `define FAKE_MODE_ADDR 1
