#include <sys/types.h> 
#include <sys/socket.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <netinet/udp.h>
#include <netinet/ip.h>
#include <netdb.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "sock_conn.h"


int sock_conn(int type,int sock_type,int is_client,char *host,char *port,
	      struct sock_conn_str *sock)
/*
  type: AF_UNIX or AF_INET (using file system or the network).

  sock_type: SOCK_DGRAM*** or SOCK_STREAM (udp or tcp).

  is_client: 
  .    in case of sock_type=SOCK_STREAM 
  .      0 - it would work as a server. It will run bind and listen(fd,1)
  .      !=0 - it will consider as client and will run connect.
  .    in case of sock_type=SOCK_DGRAM
  .      0 - will work as server and will run "bind".
  .      !=0 - just create the socket.

  host: it is the filename for AF_UNIX. 
  .     For AF_INET it would be the server address.

  port: 
  .  for AF_UNIX - it is ignored; 
  .      AF_INET - it would be the port which would be connected.
  .                (if the port is 10000 which want to connect or be used,
  .                specify the port as "10000")

  return: On success: the file descriptor for the socket
  .   -1: the given information looks to not be fine for the "type".
  .   -2: socket error.
  .   -3: connection or bind error.
  .   -4: in case of server and sock_type=SOCK_STREAM - listen error.    
  .   -5: memory allocation problem.

  . sock - if it is not null, the connection information is included.

  *** not tested, but it would also work.
*/
{
  int fd;
  struct sockaddr *addr;
  int addrlen;
  fd=-2;
  //=============  create the socket and address ========
  if(type==AF_UNIX){
    struct sockaddr_un *pt;
    if (strlen(host)>100){
      printf("host name(filename) is too long: %d characters (100 is max)\n",
	     strlen(host));
      return(-1);
    }
    if(is_client==0)
      unlink(host);
    fd=socket(AF_UNIX,sock_type,0);
    if(fd>0){
      addrlen=sizeof(struct sockaddr_un);
      addr=(struct sockaddr *)malloc(addrlen);
      if(addr==NULL){
	return(-5);
      }
      pt=(struct sockaddr_un *)addr;
      memset(pt,0,addrlen);
      strcpy(pt->sun_path,host);
      pt->sun_family=AF_UNIX;
    }
  } else if(type==AF_INET){
    struct addrinfo hint,*res,*pt;

    printf("AF_INET...\n");
    fflush(stdout);
    memset(&hint,0,sizeof(hint));
    hint.ai_family=type;
    hint.ai_socktype=sock_type;
    hint.ai_protocol=0;
    if(getaddrinfo(host, port, &hint, &res)==0){
      for(pt=res;pt!=NULL && fd<0;pt=pt->ai_next){
	printf("%d %d %d\n",pt->ai_family,pt->ai_socktype,pt->ai_protocol);
	if(pt->ai_family==type &&
	   pt->ai_socktype==sock_type ){//&&
	    //pt->ai_protocol==0){
	  fd=socket(pt->ai_family,pt->ai_socktype,pt->ai_protocol);
	  if(fd>0){
	    addrlen=pt->ai_addrlen;
	    printf("address len: %d\n",addrlen);
	    fflush(stdout);
	    addr=(struct sockaddr *)malloc(addrlen);
	    if(addr==NULL){
	      printf("Error while allocating ...\n");
	      return(-5);
	    }
	    memcpy(addr,pt->ai_addr,addrlen);
	  }
	}
      }
      freeaddrinfo(res);
    } else {
      printf("getaddrinfo error\n");
    }
  } else {
    return(-1);
  }
  if(fd<0){
    //printf("Could not open a new socket ...\n");
    return(-2);
  }

  //======== bind/listen or connect if needed ============
  if(is_client){
    if(sock_type==SOCK_STREAM){
      //try to connect.
      if(connect(fd,addr,addrlen)!=0){
	free(addr);
	return(-3);
      }
    }
  } else {
    if(bind(fd,addr,addrlen)!=0){
      free(addr);
      return(-3);
    }
    printf("sever bind...\n");
    if(sock_type==SOCK_STREAM){
      if(listen(fd,1)!=0){
	close(fd);
	free(addr);
	return(-4);
      }
      printf("Server listen\n");
    }
  }
  //======== copy addres to sock ==============
  if(sock!=NULL){
    sock->fd=fd;
    sock->addrlen=addrlen;
    sock->addr=(struct sockaddr *)malloc(addrlen);
    if(sock->addr==NULL){
      close(fd);
      return(-5);
    }
    memcpy(sock->addr,addr,addrlen);
  }

  free(addr);
  return(fd);
}

void sock_conn_finish(struct sock_conn_str *sock)
{
  if(sock!=NULL){
    if(sock->addr!=NULL){
      free(sock->addr);
      sock->addr=NULL;
    }
    sock->addrlen=0;
    close(sock->fd);
    sock->fd = -1;
  }
}
