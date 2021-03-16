#include "shwr_evt_defs.h"
#include "xparameters.h"
#include "sde_trigger_defs.h"

int read_evt_init();
int read_evt_end();
int read_evt_read(struct shwr_evt_raw *shwr);
void FeShwrRead_test(int nevts);
