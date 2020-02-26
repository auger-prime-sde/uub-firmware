//Definiciones de las funciones declaradas en sem_handler.h
#include"semhandler.h"		//PORQUE DEBO COMENTARLO???SINO DA DOBLE DECLARACION DE LA FUNCION...
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
//#define SLOW_CONTROL_SEMAPHORE "SLOW_CONTROL" //Name of semaphore
/*
struct slow_control_handler{
  sem_t *sem_handler;
} h;
*/
struct slow_control_handler h;

//Named Semaphore...
int slow_control_init(){
   h.sem_handler = sem_open(SLOW_CONTROL_SEMAPHORE, O_CREAT, 0644, 1);
	//printf("%x - ", h.sem_handler);
	if(h.sem_handler!=SEM_FAILED)
   		printf("Function init OK\n");
	else
		printf("sem_open() failed.  errno:%d\n", errno);
	return(0);
}

int slow_control_access(struct slow_control_handler h){
	int status=sem_wait(h.sem_handler);
  	if(status==0){
		//printf("Function access OK\n");
     		//sem_post( h.sem_handler );
     		return(0); //no error.
  		}
	else{
		printf("access error\n");
     		return(1); //error while use semaphore.
		}
}

int slow_control_release(struct slow_control_handler h){
	int status=sem_post(h.sem_handler);
  	if(status==0){
		//printf("Function release OK\n");
	     	//sem_post( h.sem_handler );
	     	return(0); //no error.
  		}
	else{
		printf("release error\n");
	     	return(1); //error while use semaphore.
		}
}



int slow_control_close(struct slow_control_handler h)
{
   	if(sem_close(h.sem_handler)==0){
		printf("Function close OK\n");
		return(0); //no error.
		}
	else{
		printf("Close error\n");
	     	return(1); //error while use semaphore.
		}
}


//Remove the name of semaphore
int slow_control_finish(int usr_number)
{
   	if(sem_unlink(SLOW_CONTROL_SEMAPHORE)==0){
		printf("Function unlink OK in user #%d\n",usr_number);
		return(0); //no error.
		}
	else{
		printf("Function Unlink error in user #%d\n",usr_number);
	     	return(1); //error while use semaphore.
		}
}
