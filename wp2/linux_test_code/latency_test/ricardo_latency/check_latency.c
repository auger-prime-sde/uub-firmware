//this code would be interesting to get evts directly reading the
// event data from the Programmable Logic

#include <stdio.h>
#include <stdlib.h>
#include <sched.h>
#include "read_evt.h"

struct times
{
  uint32_t second,ticks;
  uint32_t latency;
  uint32_t rd_status;
  uint32_t status;

};

int main(int argc,char *argv[])
{
  uint32_t trig_def[256];
  struct shwr_evt_complete evt;
  struct shwr_evt_raw *ev;
  int flag,n,i,j,n_ev_max;
  int offset;
  int format;

  int ntt;
  struct times tt[1000];
  struct sched_param sched_p;

  sched_p.sched_priority=50;
  
  sched_setscheduler(0,SCHED_FIFO, &sched_p);
  n_ev_max=100;
  
  if(read_evt_init(1)==0){
    n=0;
    read_evt_trig_def(trig_def);
    ntt=0;
    while(n<n_ev_max){
      flag=read_evt_read(&evt);
      if(flag==0){
        ev=&(evt.raw);
        tt[ntt].latency     = evt.extra.buff_latency;
        tt[ntt].rd_status = evt.extra.radio_info.status_flag;
        tt[ntt].second      = evt.raw.ev_gps_info.second;
        tt[ntt].ticks       = evt.raw.ev_gps_info.ticks;
        tt[ntt].status = evt.raw.buffer_ev_status;
        ntt++;
        if(100<ntt){
          for(i=0;i<ntt;i++){
            j=(tt[i].status >> 4) & 0xF;
            printf("%3d %d %8.1f   %8d   %08x %08x %x %3x %3x\n",
                   i,
                   tt[i].second,
                   tt[i].ticks/120.,
                   tt[i].latency,
                   tt[i].rd_status,
                   tt[i].status,j,tt[i].status&0x3,(tt[i].status>>2)&0x3);
          }
          ntt=0;
        }
      }
    }
  } 
}    
