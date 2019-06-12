#include <stdint.h>
#include <time.h>
#define GPS_OFFSET 315964800

enum
  {
    GPS_MSG_INVALID,
    GPS_MSG_TYPE_HB,
    GPS_MSG_TYPE_HN,
    GPS_MSG_TYPE_HA,
    GPS_MSG_TYPE_BB,
    GPS_MSG_TYPE_AS,
    GPS_MSG_TYPE_CJ,
    GPS_MSG_TYPE_BO
  };


struct hb_msg
{
  int month;
  int day;
  int year;
  int hour;
  int min;
  int sec;

  uint32_t frac;

  int32_t lat_mas;
  int32_t long_mas;
  int32_t h_cm;
  int32_t zero; /*according M12M documentation it would be always 0 */

  int v_3D;
  int v_2D;

  int hh_2D;

  int dd;

  int n_visible;
  int n_tracked;

  uint16_t status;

  char serial[12]; /*normally it use only 6 bytes (+1 for '\0' character).
		     Anyway, it is considering 12 to make it multiple of 4
		     and for possible extra character.
		   */

  time_t gps_sec; /*this is the only parameter which is not sent directly by
		    the GPS receiver, but it is calculated using the mktime
		    function from the glibc */
};

struct hn_msg
{
  char pulse;
  char sync;
  char sol;
  char stat;
  int svids;
  unsigned short accuracy;
  signed char sawtooth;
  //double gpsst[12];
};

typedef struct ha_sat ha_sat;

struct ha_sat
{
  char satid;
  char trakmode;
  unsigned char sigstrength;
  unsigned char iode;
  short chanstat;
};

struct ha_msg
{
  char month;
  char day;
  short year;
  char hours;
  char minutes;
  char seconds;
  unsigned int frac;

  int lat;
  int lon;
  int height;
  int msl;

  int ulat; //unfiltered coords
  int ulon;
  int uheight;
  int umsl;

  unsigned short speed3d;
  unsigned short speed2d;
  unsigned short heading;
  unsigned short dop;

  char vissats;
  char traksats;
  ha_sat sats[12];

  short recstat;

  short clockbias;
  int oscoff;
  short osctemp;

  char timemode;

  char gmtoffsign;
  char gmtoffhour;
  char gmtoffmin;

  char id[6];
};

typedef struct bb_sat bb_sat;

struct bb_sat
{
  char satid;
  short dop;
  unsigned char elev;
  short azim;
  char health;
};

struct bb_msg 
{
  char number;
  bb_sat sats[12];
};

struct cj_msg
{
  char msg[287]; //294-4 for header -2 for /n/r -1 for checksum
};

typedef struct en_sat en_sat;

struct en_sat
{
 char satid;
 unsigned int frac;
};

struct en_msg
{
  unsigned char outrate;
  char onoff;
  short alarmlimit;
  char control;
  char pulstat;
  char pulsync;
  char solstat;
  char traimstat;
  short accuracy;
  char sawtooth;
  en_sat sats[8];
};

typedef struct ea_sat ea_sat;

struct ea_sat
{
  char satid;
  char trak;
  unsigned char noise;
  char statflag;
};

struct ea_msg
{
  char month;
  char day;
  short year;
  char hours;
  char minutes;
  char seconds;
  unsigned int frac;

};

struct as_msg
{
  int lat;
  int lon;
  int alt;
  char alt_type;
};


unsigned char gps_receiver_xormsg(unsigned char *buff,int size);
int gps_receiver_gen_msg(int fd,char *cmd,char *compl,int ncompl);
//int gps_receiver_gen_msg(char *msg,char *cmd,int ncmd);
int gps_receiver_init();
int gps_receiver_config_request(int fd,int mode,int32_t *position);

int gps_receiver_get_info_Hb(struct hb_msg *p,unsigned char *msg);
uint32_t gps_receiver_check( struct hb_msg *p);
void gps_receiver_show_hb_param(struct hb_msg *p);

int gps_receiver_read_msg(int fd,unsigned char *msg,int read_flag);
//int gps_receiver_process(unsigned char *msg,int len,struct hb_msg *hb,struct hn_msg *hn);
unsigned char *gps_receiver_process(unsigned char *msg,int len,int *msg_type_out,int *len_out);

//added by Rob Halliday, 10/18
void gps_receiver_show_hn_param(struct hn_msg *p);
int gps_receiver_get_info_Hn(struct hn_msg *p,unsigned char *msg);
//added by Rob Halliday 1/27/17
int gps_receiver_get_info_As(struct as_msg *p,unsigned char *msg);
int gps_receiver_get_info_Bb(struct bb_msg *p,unsigned char *msg);
int gps_receiver_get_info_Cj(struct cj_msg *p,unsigned char *msg);
int gps_receiver_get_info_Ha(struct ha_msg *p,unsigned char *msg);

