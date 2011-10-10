/* RMlicelUSP.h -- defines, typedefs, and data structures for reading
   Raymetrics/licel data files @USP.
 */
#ifndef _RMLICELUSP_H
#define _RMLICELUSP_H

#include <stdlib.h> /* int32_t */
#include <string.h> /* strcpy */
#include <stdio.h> /* all file IO stuff */
#include <math.h> /* pow() */

//#include <malloc.h>
//#include <ctype.h>
//#include <time.h>
//#include <limits.h>
#include "iostream"

/*
  1-byte signed int = signed char  = int8_t
  2-byte signed int = signed short = int16_t
  4-byte signed int = signed int   = int32_t
  8-byte signed int = signed long  = int64_t

  1-byte unsigned int = unsigned char  = u_int8_t
  2-byte unsigned int = unsigned short = u_int16_t
  4-byte unsigned int = unsigned int   = u_int32_t
  4-byte unsigned int = unsigned long  = u_int64_t

  4-byte real = float
  8-byte real = double
 */

//typedef int32_t bin;

typedef int32_t bin;
typedef char single;

typedef struct{
    int YY;
    int MM;
    int DD;
    int hh;
    int mn;
    int ss;
} date;

typedef struct{
    int active; // active (1) non-active (0)
    int photons; // photons (1) analog (0)
    int elastic; // elastic (1) raman (2)
    int ndata; // number of data points
    int pmtv; // pmt high voltage (V)
    float binw; // bin width (m)    
    int wlen; // wavelength (nm)
    single pol; // polarization (o, p, s)
    int bits; // adc bits (for analog channels)
    int nshoots; 
    float discr;// voltage range or discriminator level
    char tr[3];
    bin *raw; // raw data in original data format
    float *phy; // physical data converted to 4-byte float
} channel;

typedef struct{
    char file[80]; // file name as written in header
    char site[80]; // site name 
    date start; // date
    date end; // date
    int alt; // altitude (m)
    float lon; // longitute (deg)
    float lat; // latitude (deg)
    int zen; // zenith (deg)
    int idum;
    float T0; // reference surface temperature
    float P0; // reference surface pressure
    int nshoots; // number of shoots
    int nhz; // repetition rate (Hz)
    int nshoots2; // number of shoots
    int nhz2; // repetition rate (Hz)
    int nch; // number of channels
    channel *ch;
} RMDataFile;

extern void Free_RMDataFile(RMDataFile *rm);
extern void Init_RMDataFile(RMDataFile *rm);
extern int file_error(FILE *filep);
extern bool DateLT(date d1, date d2);

extern void channel_debug(channel ch);
extern void channel_readerror();
extern void channel_read  (FILE *fp, channel*ch);
extern void channel_printf(FILE *fp, channel ch, const char* beg, const char* sep);

extern void header_debug(RMDataFile rm);
extern void header_read_error();
extern void header_read  (FILE *fp, RMDataFile*rm);
extern void header_printf(FILE *fp, RMDataFile rm, 
                          const char* beg, const char* sep, const char* sep2);

extern void raw_debug(RMDataFile rm, int imax);
extern void raw_write(FILE *fp, RMDataFile rm);
extern void raw_printf(FILE *fp, RMDataFile rm, int imax, const char* sep);

extern void phy_debug(RMDataFile rm, int imax);
extern void phy_printf(FILE *fp, RMDataFile rm, int imax, const char* sep);

extern void profile_debug(RMDataFile rm);
extern void profile_read (const char* fname, RMDataFile *rm);
extern void profile_add (RMDataFile *acum, RMDataFile toadd);
extern void profile_write(FILE *fp, RMDataFile rm);
extern void profile_printf(FILE *fp, RMDataFile rm, int imax, 
                           const char* beg, const char* sep, const char* sep2);

#endif /* _RMLICELUSP_H */
