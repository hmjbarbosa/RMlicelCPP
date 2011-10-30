/* TimeDate.h -- Simple time and date routines.
 */
#ifndef _TIMEDATE_H
#define _TIMEDATE_H

#include <stdlib.h> /* int32_t */
#include <stdio.h> /* all file IO stuff */
#include <math.h>

#include "iostream"

typedef struct{
    int YY;
    int MM;
    int DD;
    int hh;
    int mn;
    int ss;
} date;

#define secinday 86400

// less-than comparison of two dates
extern bool DateLT(date d1, date d2);

// date to string
extern std::string YMD2String(date d1);
// time to string
extern std::string Time2String(date d1); 

// date/time to julian days
extern void Date2JD(date d1, double *jd);
// julian days to date/time
extern void JD2Date(date *d1, double jd);

// time difference between two dates
extern int SecDiff(date d1, date d2);
extern int DayDiff(date d1, date d2);

#endif /* _TIMEDATE_H */
