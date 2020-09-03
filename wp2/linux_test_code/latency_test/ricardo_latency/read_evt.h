#include <shwr_evt_defs.h>

int read_evt_init(int uio);
int read_evt_end();
int read_evt_read(struct shwr_evt_complete *shwr);
void read_evt_trig_def(uint32_t *buff);
