#include "TimeDate.h"

/*
  Function: DateLT
  Description: less-than comparison of two dates
  Author: hbarbosa
  Date: 30 aug 2011
 */
bool DateLT(date d1, date d2) 
{
  if (d1.YY < d2.YY) return(true);
  if (d1.YY > d2.YY) return(false);
  if (d1.MM < d2.MM) return(true);
  if (d1.MM > d2.MM) return(false);
  if (d1.DD < d2.DD) return(true);
  if (d1.DD > d2.DD) return(false);

  if (d1.hh < d2.hh) return(true);
  if (d1.hh > d2.hh) return(false);
  if (d1.mn < d2.mn) return(true);
  if (d1.mn > d2.mn) return(false);
  if (d1.ss < d2.ss) return(true);
  if (d1.ss > d2.ss) return(false);

  return(false);
}

/*
  Function: YMD2Char
  Description: convert date to string
  Author: hbarbosa
  Date: 30 oct 2011
 */
std::string YMD2String(date d1) 
{
  char strdate[10];
  sprintf(strdate,"%02d/%02d/%04d",d1.DD,d1.MM,d1.YY);
  return(strdate);
}

/*
  Function: Time2Char
  Description: convert time to string
  Author: hbarbosa
  Date: 30 oct 2011
 */
std::string Time2String(date d1) 
{
  char strdate[8];
  sprintf(strdate,"%02d:%02d:%02d",d1.hh,d1.mn,d1.ss);
  return(strdate);
}

/*
  Function: Date2JD
  Description: converts date to julian date
  Author: hbarbosa
  Date: 30 oct 2011
 */
void Date2JD(date d1, double *jd) 
{
  // http://aa.usno.navy.mil/software/novas/novas_c/novas.c
  // Fliegel, H. & Van Flandern, T.  Comm. of the ACM, Vol. 11, No. 10,
  //     October 1968, p. 657.

   long int jd12h;

   double 
     hour = d1.hh+(d1.mn+(d1.ss/60.))/60.;

   long int
     lday   = (long) d1.DD,
     lmonth = (long) d1.MM,
     lyear  = (long) d1.YY;

   // Adjust BC years
   if ( lyear < 0 ) lyear++;
   
   jd12h = lday - 32075L + 
     1461L * (lyear + 4800L + (lmonth - 14L) / 12L) / 4L +
     367L * (lmonth - 2L - (lmonth - 14L) / 12L * 12L) / 12L - 
     3L * ((lyear + 4900L + (lmonth - 14L) / 12L) / 100L) / 4L;

   *jd = (double) jd12h - 0.5 + hour / 24.0;
}

/*
  Function: JD2Date
  Description: converts julian date to date
  Author: hbarbosa
  Date: 30 oct 2011
 */
void JD2Date(date *d1, double jd) 
{
  double hour, min, sec;
  long int jd12h;
  long int t1, t2, yr, mo;

  hour=(jd+0.5-int(jd+0.5))*24.; d1->hh=int(hour);
  min=(hour-int(hour))*60.;      d1->mn=int(min);
  sec=(min-int(min))*60.;        d1->ss=int(sec);

  jd12h = int(jd+0.5);

  t1 = jd12h + 68569L;
  t2 = 4L * t1 / 146097L;
  t1 = t1 - ( 146097L * t2 + 3L ) / 4L;
  yr = 4000L * ( t1 + 1L ) / 1461001L;
  t1 = t1 - 1461L * yr / 4L + 31L;
  mo = 80L * t1 / 2447L;
  d1->DD = (int) ( t1 - 2447L * mo / 80L );
  t1 = mo / 11L;
  d1->MM = (int) ( mo + 2L - 12L * t1 );
  d1->YY = (int) ( 100L * ( t2 - 49L ) + yr + t1 );
  
  // Correct for BC years
  if ( d1->YY <= 0 )
    d1->YY -= 1;

}

/*
  Function: SecDiff
  Description: time difference (seconds) between two dates
  Author: hbarbosa
  Date: 30 oct 2011
 */
int SecDiff(date d1, date d2)
{
  double j1, j2;
  Date2JD(d1, &j1);
  Date2JD(d2, &j2);
  return(int(fabs(j2-j1)*secinday+0.5));
}

/*
  Function: DayDiff
  Description: time difference (days) between two dates
  Author: hbarbosa
  Date: 30 oct 2011
 */
int DayDiff(date d1, date d2)
{
  double j1, j2;
  Date2JD(d1, &j1);
  Date2JD(d2, &j2);
  return(int(fabs(j2-j1))+0.5);
}

