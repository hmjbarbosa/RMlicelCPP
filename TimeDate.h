/* TimeDate.h -- Simple time and date routines.
 */
#ifndef _TIMEDATE_H
#define _TIMEDATE_H

#include <stdlib.h> /* int32_t */
#include <stdio.h> /* all file IO stuff */
#include <math.h>
#include "iomanip" 

#include "iostream"

typedef struct{
    int YY;
    int MM;
    int DD;
    int hh;
    int mn;
    int ss;
    double jd;
    float utc;
} date;

#define secinday 86400
#define mininday 1440
#define hourinday 24

//#define USEUTC true
#define UTC -4 // local time zone

#define jd2010 2455197.5
#define jd1900 2415020.5

// initialize date with -999
extern void ResetDate(date *d1);

// round date d1 to the nearest full minute and save it to d2
extern void RoundMinutes(date d1, date *d2); 

// initialize with a actual date
extern void InitDateYMD(date *d1, int YY, int MM, int DD, 
                         int hh, int mn, int ss, float utc);

// initialize with a actual julian date
extern void InitDateJD(date *d1, double jd, float utc);

// less-than comparison of two dates
extern bool DateLT(date d1, date d2);

// write date/time in netcdf format
// YYYY-MM-DD hh:mm:ss UTC
extern std::string Date2nc(date d1);

// date to string
extern std::string YMD2String(date d1, char sep);
extern std::string DMY2String(date d1, char sep);

// time to string
extern std::string Time2String(date d1); 

// date/time to julian days
extern void Date2JD(date d1, double *jd);
// julian days to date/time
extern void JD2Date(date *d1, double jd);

// time difference between two dates
extern int SecDiff(date d1, date d2);
extern int MinDiff(date d1, date d2);
extern int HourDiff(date d1, date d2);
extern int DayDiff(date d1, date d2);

#endif /* _TIMEDATE_H */
