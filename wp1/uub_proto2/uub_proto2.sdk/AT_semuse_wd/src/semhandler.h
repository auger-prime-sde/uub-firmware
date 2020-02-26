// Solo las declaraciones de las funciones semáforo
#ifndef _sem_handler_h_
#define _sem_handler_h_

#include <semaphore.h>
#include <sys/sem.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#define SLOW_CONTROL_SEMAPHORE "SLOW_CONTROL"

struct slow_control_handler{
  sem_t *sem_handler;
};//previously defined here as "h";

//Declarations
int slow_control_init();
int slow_control_access(struct slow_control_handler h);
int slow_control_release(struct slow_control_handler h);
int slow_control_close(struct slow_control_handler h);
int slow_control_finish(int);
#endif
