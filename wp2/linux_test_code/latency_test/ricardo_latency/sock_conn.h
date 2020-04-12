#ifndef _SOCK_CONN_H_
#define _SOCK_CONN_H_

#include <sys/types.h> 
#include <sys/socket.h>

struct sock_conn_str
{
  int fd;
  struct sockaddr *addr;
  int addrlen;
};

int sock_conn(int type,int sock_type,int is_client,char *host,char *port,
	      struct sock_conn_str *sock);
void sock_conn_finish(struct sock_conn_str *sock);


#endif
