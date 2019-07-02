/*this is a very simple gps_receiver interface to get 
  basic GPS information. It is only looking for the "Hb" output
  command from the GPS receiver.
  Maybe a better implementation would be needed to look more details
  of the PPS information
*/
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#include "gps_receiver.h"
#define BUFFSIZE 1024
#define HB_MSG_LEN 54
#define HN_MSG_LEN 78
#define BB_MSG_LEN 92
#define HA_MSG_LEN 154
//#define EA_MSG_LEN 76
//#define EN_MSG_LEN 69
#define CJ_MSG_LEN 294
#define AS_MSG_LEN 20


struct gps_receiver_msg_in
{
  char *head; /*it would be only 2, but we would need to consider '\0' character */
  int msg_len;
};
struct gps_receiver_msg_in msg_type[]=
  {
    {"Hb",HB_MSG_LEN},  //struct done
    {"Hn",HN_MSG_LEN},  //struct done
    {"Ha",HA_MSG_LEN},  //struct done
    {"Bb",BB_MSG_LEN},  //struct done
//    {"Ea",EA_MSG_LEN},  //since a UUB will never run these, I will leave them out
    {"Cj",CJ_MSG_LEN},  //struct done
//    {"En",EN_MSG_LEN},  //see Ea
    {"As",AS_MSG_LEN},  
    {NULL,0}
  };

/*7 is the minimum message len "@@XXCyx", where 
  XX is the command "Ha", "Hb", ..., 
  C is the "checksum", 
  yx - end of message
*/
#define GPS_RECEIVER_MIN_MSG_LEN 7

unsigned char gps_receiver_xormsg(unsigned char *buff,int size)
{
  char chksum=0;
  int i;
  for(i=0;i<size;i++){
    chksum^=buff[i];
  }
  return chksum;
}
int gps_receiver_gen_msg(int fd,char *cmd,char *compl,int ncompl);
//int gps_receiver_gen_msg(char *msg,char *cmd,int ncmd)
{
  int n;
  msg[0]='@';
  msg[1]='@';
  n=2;
  memcpy(msg+n,cmd,ncompl);
  n+=ncmd;
  *(msg+n)=gps_receiver_xormsg(cmd,ncmd);
  n++;
  *(msg+n)=0x0D;
  n++;
  *(msg+n)=0x0A;
  return(n+1);
}


int gps_receiver_init()
{
  /*this function just set the serial port communication */
  int gpsuart; 
  struct termios newtio;
  gpsuart=open("/dev/ttyUL1", O_RDWR | O_NOCTTY );
  if(gpsuart<0){
    printf("Not possible to open the /dev/ttyUL1 device\n");
    exit(1);
  }
  /*need to set the data communication in RAW mode */
  if(tcgetattr(gpsuart, &newtio)<0){
    printf("Error while trying to get /dev/ttyUL1 previous configuraton\n");
    exit(1);
  }
  newtio.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP
			  | INLCR | IGNCR | ICRNL | IXON);
  newtio.c_oflag &= ~OPOST;
  newtio.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
  newtio.c_cflag &= ~(CSIZE | PARENB);
  newtio.c_cflag |= CS8;
  tcflush(gpsuart, TCIFLUSH);
  
  if(tcsetattr(gpsuart,TCSANOW,&newtio)){
    printf("Error while trying to reset /dev/ttyUL1\n");
    exit(1);
  }
  return(gpsuart);  
}


void gps_receiver_config_request(int fd)
{
  /*disabling Ha, Hn report and making the Hb activer
    it also set the receiver to GPS time output, instead of UTC */
  char cmd[4];
  char buff[15];
  int nbuff,nw,i;
  /*disable Ha and Hn periodical reports */
  memcpy(cmd,"Ha",2);cmd[2]=0;
  nbuff=gps_receiver_gen_msg(buff,cmd,3);
  nw=write(fd,buff,nbuff);
  
  /*enable Hn */ 
  memcpy(cmd,"Hn",2);cmd[2]=1;
  nbuff=gps_receiver_gen_msg(buff,cmd,3);
  nw=write(fd,buff,nbuff);

  /*enable Hb report every second in GPS time */
  memcpy(cmd,"Aw",2);
  cmd[2]=0;
  nbuff=gps_receiver_gen_msg(buff,cmd,3);
  nw=write(fd,buff,nbuff);
  
  memcpy(cmd,"Hb",2);
  cmd[2]=1;
  nbuff=gps_receiver_gen_msg(buff,cmd,3);
  nw=write(fd,buff,nbuff);
  if(nw!=nbuff){
    printf("Error while request \"Hb\" data \n");
    exit(0);
  }
  fsync(fd);
}

int gps_receiver_get_info_Hb(struct hb_msg *p,unsigned char *msg)
{
  p->month=msg[0];
  p->day=msg[1];
  p->year=msg[2]<<8 | msg[3];
  p->hour=msg[4];
  p->min=msg[5];
  p->sec=msg[6];
  p->frac=(msg[7]<<24) | (msg[8]<<16) | (msg[9]<<8) | msg[10];
  p->lat_mas=(msg[11]<<24) | (msg[12]<<16) | (msg[13]<<8) | msg[14];
  p->long_mas=(msg[15]<<24) | (msg[16]<<16) | (msg[17]<<8) | msg[18];
  p->h_cm=(msg[19]<<24) | (msg[20]<<16) | (msg[21]<<8) | msg[22];
  p->zero=(msg[23]<<24) | (msg[24]<<16) | (msg[25]<<8) | msg[26];
  p->v_3D=(msg[27]<<8) | msg[28];
  p->v_2D=(msg[29]<<8) | msg[30];
  p->hh_2D=(msg[31]<<8) | msg[32];
  p->dd=(msg[33]<<8) | msg[34];
  p->n_visible=msg[35];
  p->n_tracked=msg[36];
  p->status=(msg[37]<<8) | msg[38];
  memcpy(p->serial,msg+39,6); 
  if(p->zero!=0){
    return(1);
  }
  return(0);
}

int gps_receiver_get_info_Ha(struct ha_msg *p,unsigned char *msg)
{
  p->month=msg[0];
  p->day=msg[1];
  p->year=msg[2]<<8 | msg[3];
  p->hours=msg[4];
  p->minutes=msg[5];
  p->seconds=msg[6];
  p->frac=(msg[7]<<24) | (msg[8]<<16) | (msg[9]<<8) | msg[10];
  p->lat=(msg[11]<<24) | (msg[12]<<16) | (msg[13]<<8) | msg[14];
  p->lon=(msg[15]<<24) | (msg[16]<<16) | (msg[17]<<8) | msg[18];
  p->height=(msg[19]<<24) | (msg[20]<<16) | (msg[21]<<8) | msg[22];
  p->msl=(msg[23]<<24) | (msg[24]<<16) | (msg[25]<<8) | msg[26];
  p->ulat=(msg[27]<<24) | (msg[28]<<16) | (msg[29]<<8) | msg[30]; //unfiltered coords
  p->ulon=(msg[31]<<24) | (msg[32]<<16) | (msg[33]<<8) | msg[34];
  p->uheight=(msg[35]<<24) | (msg[36]<<16) | (msg[37]<<8) | msg[38];
  p->umsl=(msg[39]<<24) | (msg[40]<<16) | (msg[41]<<8) | msg[42];

  p->speed3d=(msg[43]<<8) | msg[44];
  p->speed2d=(msg[45]<<8) | msg[46];
  p->heading=(msg[47]<<8) | msg[48];
  p->dop=(msg[49]<<8) | msg[50];

  p->vissats=msg[51];
  p->traksats=msg[52];

  int i;
  int offset=52;
  for(i=0;i<12;i++){
    p->sats[i].satid=msg[offset+1+6*i];
    p->sats[i].trakmode=msg[offset+2+6*i];
    p->sats[i].sigstrength=msg[offset+3+6*i];
    p->sats[i].iode=msg[offset+4+6*i];
    p->sats[i].chanstat==(msg[offset+5+6*i]<<8) | msg[offset+6+6*i];
  }
  p->recstat=(msg[125]<<8) | msg[126];

  p->clockbias=(msg[127]<<8) | msg[128];
  p->oscoff=(msg[129]<<24) | (msg[130]<<16) | (msg[131]<<8) | msg[132];
  p->osctemp=(msg[133]<<8) | msg[134];

  p->timemode=msg[135];

  p->gmtoffsign=msg[136];
  p->gmtoffhour=msg[137];
  p->gmtoffmin=msg[138];

  memcpy(p->id,msg+139,6);
  return(0);
}

int gps_receiver_get_info_As(struct as_msg *p,unsigned char *msg)
{
  p->lat=(msg[0]<<24) | (msg[1]<<16) | (msg[2]<<8) | msg[3];
  p->lon=(msg[4]<<24) | (msg[5]<<16) | (msg[6]<<8) | msg[7];
  p->height=(msg[8]<<24) | (msg[9]<<16) | (msg[10]<<8) | msg[11];
  p->alt_type=msg[12];

  return(0);
}

int gps_receiver_get_info_Bb(struct bb_msg *p,unsigned char *msg)
{
  p->number=msg[0];
  int i;
  const int offset=0; //left in for debugging, should be deleted if it works
  int max=(int)msg[0];
  for(i=0;i<max;i++){
    p->sats[i].satid=msg[offset+1+7*i];
    p->sats[i].dop=(msg[offset+2+7*i]<<8) | msg[offset+3+7*i];
    p->sats[i].elev=msg[offset+4+7*i];
    p->sats[i].azim=(msg[offset+5+7*i]<<8) | msg[offset+6+7*i];;
    p->sats[i].health=msg[offset+7+7*i]; 
  }

  return(0);
}

int gps_receiver_get_info_Hn(struct hn_msg *p,unsigned char *msg)
{
  p->pulse=msg[0];
  p->sync=msg[1];
  p->sol=msg[2];
  p->stat=msg[3];
  p->svids=(msg[4]<<24) | (msg[5]<<16) | (msg[6]<<8) | msg[7];
  p->accuracy=(msg[8]<<8) | msg[9];
  p->sawtooth=msg[10];
  printf("TRAIM Status: %d \n",p->sol);
  //int n;
  //int j;
  //for(n=0;n<12;n++){
  //  j=5*n;
  //  p->gpsst[n]= (msg[10+1+j]<<32) | (msg[10+2+j]<<24) | (msg[10+3+j]<<16) | (msg[10+4+j]<<8) | msg[10+5+j];
  //}

  return(0);
}

int gps_receiver_get_info_Cj(struct cj_msg *p,unsigned char *msg)
{
  memcpy(p->msg,msg,287);
  return(0);
}

uint32_t gps_receiver_check( struct hb_msg *p)
{
  uint32_t ret;
  ret=0;
  struct tm t;

  if(p->month<1   || 12<p->month)       ret|=0x1;
  if(  p->day<1   || 31<p->day  )       ret|=0x2;
  if(p->year<1998 || 2079<p->year )     ret|=0x4;
  if(p->hour<0    || 23  <p->hour )     ret|=0x8;
  if(p->min<0     || 59  <p->min )      ret|=0x10;
  if(p->sec<0     || 60  <p->sec )      ret|=0x20;

  if(ret==0){
    t.tm_sec=p->sec;
    t.tm_min=p->min;
    t.tm_hour=p->hour;
    t.tm_mon=p->month-1;
    t.tm_mday=p->day;
    t.tm_year=p->year-1900;
    t.tm_isdst=0;
    p->gps_sec=mktime(&t)-GPS_OFFSET;
    if(500000000 < p->frac){
      p->gps_sec++; /* sometimes the reported second corresponds to the
		       end of the previous second. */
    }
  }
  
  return(ret);
}

void gps_receiver_show_hb_param(struct hb_msg *p)
{
  printf("%04d/%02d/%02d_%02d:%02d:%02d.%09d (%d) %2d %2d \n",
	 p->year,p->month,p->day,p->hour,p->min,p->sec,p->frac,
	 p->gps_sec,p->n_visible,p->n_tracked);
  fflush(stdout);
  //printf("(lat,long,height)=(%d,%d,%d)\n",p->lat_mas,p->long_mas,p->h_cm);
  //printf("(V,v,h)=(%d,%d,%d)\n",p->v_3D,p->v_2D,p->hh_2D);
  //printf("(visible,tracked,dd)=(%d,%d,%d)\n",p->n_visible,p->n_tracked,p->dd);
  //printf("Status=%04x\n",p->status);
  //printf("%s\n",p->serial);
}

void gps_receiver_show_hn_param(struct hn_msg *p)
{
  printf("Sawtooth: %i \n",p->sawtooth);
  fflush(stdout);
}


/*the function read one data from the port (the GPS receiver),
  and check if there are enough data for a complete message.
  return 0: in case there are not any message
  .    nb: number of bytes of one complete message,
  .       the message will be copied to "msg"
  .    -1: in case of error
   
  if read_flag!=0: it will read more data from the receiver before
  .   try to check for a valid message.
*/
int gps_receiver_read_msg(int fd,unsigned char *msg,int read_flag)
{
  static int nbuff=0;
  static char buff[BUFFSIZE];
  static int msg_len=GPS_RECEIVER_MIN_MSG_LEN;
  char *pt;
  int offset,nr;
  int npass;
  int aux;
  int i;
  char headxor;
  if(read_flag){
    nr=read(fd,buff+nbuff,BUFFSIZE-nbuff);
    if(nr<=0){
      return(-1);
    }
    nbuff+=nr;
  }
  //printf("msg_len, nbuff=%d,%d\n",msg_len,nbuff);
  while(msg_len<=nbuff){ 
    pt=(char *)memmem(buff,nbuff,"@@H",3);
    if(pt==NULL){
      /*through the previous message which looks to have no relation 
	with the GPS information. However, it keeps the last 4 bytes
	because it may be related with the message which we are 
	interested
      */
      memmove(buff,buff+nbuff-3,3);
      nbuff=3;    /* the first if statement should check most of the
		     time, the second if statement checks if @@H has
		     been found in the buffer. It the puts the message
		     at the front of the buffer, then sets nbuff to
		     the end of the message */
      return(0);
    }
    
    /*at this point, there would have a valid header */
    
    offset=pt-buff;
    //printf("offset: %d\n",offset);
    if(offset>0){   
      /*throwing away data which looks to be not related with any message */
      memmove(buff,pt,nbuff-offset);
      nbuff-=offset;
    }
    
    if(GPS_RECEIVER_MIN_MSG_LEN==msg_len &&  GPS_RECEIVER_MIN_MSG_LEN<=nbuff){
      //printf("check message %d\n",msg_len);
      /*depending on the message type, we need to know the message length */
      for(i=0;msg_type[i].head!=NULL; i++){
	if(memcmp(buff+2,msg_type[i].head,2)==0){
	  msg_len=msg_type[i].msg_len;
	  break;
	}
      }
      if(msg_len==GPS_RECEIVER_MIN_MSG_LEN){
	/*it have not found any valid header. It is going to discard ... */
	memmove(buff,buff+4,nbuff-4);
	nbuff-=4;
      }
    } 

    if(GPS_RECEIVER_MIN_MSG_LEN<msg_len && msg_len<=nbuff){
      /*at this point, we know the message length and it has
	enough data in buffer for a complete message */
      if(gps_receiver_xormsg(buff+2,msg_len-5) != buff[msg_len-3] ||   
	 buff[msg_len-2]!=0x0D ||
	 buff[msg_len-1]!=0x0A ) {
	/*it had some error and it is going to discard the header to
	  check for new message
	*/	
	memmove(buff,buff+4,nbuff-4);
	nbuff-=4;
	msg_len=GPS_RECEIVER_MIN_MSG_LEN;
      } else {
	/*there are a valid message */
	memcpy(msg,buff,msg_len);
	if(nbuff>msg_len){
	  memmove(buff,buff+msg_len,nbuff-msg_len);
	  nbuff-=msg_len;
	} else {
	  nbuff=0;
	}
	aux=msg_len;
	msg_len=GPS_RECEIVER_MIN_MSG_LEN;
	return(aux);
      }
    }
  }
  return(0);
}

/*The function int gps_receiver_process receive as a input 
  one complete message (*msg,len) and check if is one of
  the possible message which would be interpreted.
  Right now only the "@@Hb" and "@@Hn" are implemented.

  It returns: 
  -1: in case of some error 
  0: it does not looks to be a valid message
  1: it is and "@@Hb" message
  2: it is and "@@Hn" message
  3: it is and "@@Ha" message
  4: it is and "@@Bb" message
  5: it is and "@@As" message
  6: it is and "@@Cj" message
*/
int gps_receiver_process(unsigned char *msg,int len)
{
  if(GPS_RECEIVER_MIN_MSG_LEN<=len){
    if(memcmp((msg+2),"Hb",2)==0){ 
      return(1);
    }
    if(memcmp((msg+2),"Hn",2)==0){ 
      return(2);
    }
    if(memcmp((msg+2),"Ha",2)==0){ 
      return(3);
    }
    if(memcmp((msg+2),"Bb",2)==0){ 
      return(4);
    }
    if(memcmp((msg+2),"As",2)==0){ 
      return(5);
    }
    if(memcmp((msg+2),"Cj",2)==0){ 
      return(6);
    }
    return(0); 
  }
  return(1);
}
