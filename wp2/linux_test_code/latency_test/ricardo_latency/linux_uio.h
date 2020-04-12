#ifndef LINUX_UIO
#define LINUX_UIO

/* This is just a definition of UIO devices which is are actually
   links for the corresponding devices 
*/
/* shower buffers */
#define UIO_BUFF_SHWR_SD_0 "/dev/UIO/buff_shwr_0"
#define UIO_BUFF_SHWR_SD_1 "/dev/UIO/buff_shwr_1"
#define UIO_BUFF_SHWR_SD_2 "/dev/UIO/buff_shwr_2"
#define UIO_BUFF_SHWR_SD_3 "/dev/UIO/buff_shwr_3"
#define UIO_BUFF_SHWR_SD_4 "/dev/UIO/buff_shwr_4"

/*radio buffer */
#define UIO_BUFF_SHWR_RD_0 "/dev/UIO/buff_RD_0"

/* muon buffer */
#define UIO_BUFF_MUON_0 "/dev/UIO/buff_muon_0"
#define UIO_BUFF_MUON_1 "/dev/UIO/buff_muon_1"

/*fake buffer */
#define UIO_BUFF_FAKE_0 "/dev/UIO/buff_fake_0"
#define UIO_BUFF_FAKE_1 "/dev/UIO/buff_fake_1"

/* CONTROL */
#define UIO_CTRL_SDE  "/dev/UIO/ctrl_SDETrig"
#define UIO_CTRL_RD   "/dev/UIO/ctrl_RD"
#define UIO_CTRL_TTAG "/dev/UIO/ctrl_TTag"
#define UIO_CTRL_TEST "/dev/UIO/ctrl_test"

/* interruptions */
#define UIO_INTERRUPT_SHWR "/dev/UIO/intr_shwr" 
#define UIO_INTERRUPT_MUON "/dev/UIO/intr_muon"
#define UIO_INTERRUPT_PPS  "/dev/UIO/intr_ttag"


/* The following definitions is only used for simulation.
   It is not indented to any communication with FPGA     */
#define UIO_SIMU_SHWR "/dev/UIO/sim_intr_shwr"
#define UIO_SIMU_MUON "/dev/UIO/sim_intr_muon"
#define UIO_SIMU_TTAG "/dev/UIO/sim_intr_ttag"


#endif
