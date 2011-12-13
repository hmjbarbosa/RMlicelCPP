#include "TimeDate.h"

//ClassImp(RM_Date)

//______________________________________________________________________________
/*
  Function: Basic constructor
  Description: initialize date with -999
  Author: hbarbosa
  Date: 12 dec 2011
 */
RM_Date::RM_Date()
{
  Nullify();
}

//______________________________________________________________________________
/*
  Function: Constructor from another object
  Description: initialize date by copying from another date
  Author: hbarbosa
  Date: 12 dec 2011
 */
RM_Date::RM_Date(const RM_Date &date)
{
  yy = date.yy;
  mm = date.mm;
  dd = date.dd;
  hh = date.hh;
  mn = date.mn;
  ss = date.ss;
  jd = date.jd;
  utc = date.utc;
}

//______________________________________________________________________________
/*
  Function: Constructor from full date
  Description: initialize with a date
  Author: hbarbosa
  Date: 12 dec 2011
 */
RM_Date::RM_Date(const int year, const int mon, const int day,
                 const int hour, const int min, const int sec, 
                 const float futc)
{
  yy = year;
  mm = mon;
  dd = day;
  hh = hour;
  mn = min;
  ss = sec;
  utc = futc;

  CalcJD();
}

//______________________________________________________________________________
/*
  Function: Constructor from JD and UTC
  Description: initialize with a julian date
  Author: hbarbosa
  Date: 12 nov 2011
 */
RM_Date::RM_Date(const double julday, const float futc)
{
  utc = futc;
  jd = julday;

  CalcDate();
}

//______________________________________________________________________________
/*
  Function: RM_Date operator = 
  Description: 
  Author: hbarbosa
  Date: 12 dec 2011
 */
RM_Date& RM_Date::operator=(const RM_Date &rhs)
{
  if (this != &rhs) {
    yy = rhs.yy;
    mm = rhs.mm;
    dd = rhs.dd;
    hh = rhs.hh;
    mn = rhs.mn;
    ss = rhs.ss;
    jd = rhs.jd;
    utc = rhs.utc;
  }
  return *this;
}

//______________________________________________________________________________
/*
  Function: RM_Date operator <
  Description: 
  Author: hbarbosa
  Date: 12 dec 2011
 */
bool RM_Date::operator<(const RM_Date &rhs)
{
  return(this->jd < rhs.jd);
}

//______________________________________________________________________________
/*
  Function: RM_Date operator >
  Description: 
  Author: hbarbosa
  Date: 12 dec 2011
 */
bool RM_Date::operator>(const RM_Date &rhs)
{
  return(this->jd > rhs.jd);
}

//______________________________________________________________________________
/*
  Function: RM_Date operator ==
  Description: 
  Author: hbarbosa
  Date: 12 dec 2011
 */
bool RM_Date::operator==(const RM_Date &rhs)
{
  return(this->jd == rhs.jd);
}

//______________________________________________________________________________
/*
  Function: RM_Date destructor
  Description: 
  Author: hbarbosa
  Date: 12 dec 2011
 */
RM_Date::~RM_Date()
{
  Nullify();
}

//______________________________________________________________________________
/*
  Function: simple get functions
  Description: return specific values
  Author: hbarbosa
  Date: 12 dec 2011
*/
int RM_Date::GetYear() { return (yy); }
int RM_Date::GetMonth(){ return (mm); }
int RM_Date::GetDay()  { return (dd); }
int RM_Date::GetHour() { return (hh); }
int RM_Date::GetMin()  { return (mn); }
int RM_Date::GetSec()  { return (ss); }
float RM_Date::GetUTC()  { return (utc); }
double RM_Date::GetJD()   { return (jd); }

//______________________________________________________________________________
/*
  Function: Nullify
  Description: initialize date with -999
  Author: hbarbosa
  Date: 12 nov 2011
*/
void RM_Date::Nullify()
{
  yy=-999;
  mm=-999;
  dd=-999;
  hh=-999;
  mn=-999;
  ss=-999;
  jd=-999.;
  utc=-999.;
}

//______________________________________________________________________________
/*
  Function: RoundMinutes
  Description: round a date to the nearest minute
  Author: hbarbosa
  Date: 12 nov 2011
 */
void RM_Date::RoundMinutes()
{
  jd = double(floor(jd*double(mininday)+0.5))/double(mininday);
  CalcDate();
}


//______________________________________________________________________________
/*
  Function: Date2nc
  Description: write date/time in netcdf format
               YYYY-MM-DD hh:mm:ss UTC
  Author: hbarbosa
  Date: 12 nov 2011
 */
std::string RM_Date::write2nc()
{
  char strdate[26];
  int h, m;
  h=int(this->utc);
  m=int((this->utc-h)*60);
  sprintf(strdate,"%s %s %+03d:%02d", write2YMD('-').c_str(),
          write2hms().c_str(), h, m);
  return(strdate);
}

//______________________________________________________________________________
/*
  Function: YMD2Char
  Description: convert date to string
  Author: hbarbosa
  Date: 30 oct 2011
 */
std::string RM_Date::write2YMD(const char sep) 
{
  char strdate[10];
  sprintf(strdate,"%04d%1c%02d%1c%02d", yy,sep, mm,sep, dd);
  return(strdate);
}
std::string RM_Date::write2DMY(const char sep) 
{
  char strdate[10];
  sprintf(strdate,"%02d%1c%02d%1c%04d", dd,sep, mm,sep, yy);
  return(strdate);
}

//______________________________________________________________________________
/*
  Function: Time2Char
  Description: convert time to string
  Author: hbarbosa
  Date: 30 oct 2011
 */
std::string RM_Date::write2hms(const char sep) 
{
  char strdate[8];
  sprintf(strdate,"%02d%1c%02d%1c%02d",hh,sep,mn,sep,ss);
  return(strdate);
}

//______________________________________________________________________________
/*
  Function: CalcJD
  Description: calculates de julian date based on the current date
  Author: hbarbosa
  Date: 30 oct 2011
 */
void RM_Date::CalcJD() 
{
  // http://aa.usno.navy.mil/software/novas/novas_c/novas.c
  // Fliegel, H. & Van Flandern, T.  Comm. of the ACM, Vol. 11, No. 10,
  //     October 1968, p. 657.

   long int jd12h;

   double 
     hour = hh+(mn+(ss/60.))/60.;

   long int
     lday   = (long) dd,
     lmonth = (long) mm,
     lyear  = (long) yy;

   // Adjust BC years
   if ( lyear < 0 ) lyear++;
   
   jd12h = lday - 32075L + 
     1461L * (lyear + 4800L + (lmonth - 14L) / 12L) / 4L +
     367L * (lmonth - 2L - (lmonth - 14L) / 12L * 12L) / 12L - 
     3L * ((lyear + 4900L + (lmonth - 14L) / 12L) / 100L) / 4L;

   // julian day is integer at noon (half day through)
   jd = (double) jd12h - 0.5 + hour / 24.0;
}

//______________________________________________________________________________
/*
  Function: CalcDate
  Description: calculates date based on the value of julian date
  Author: hbarbosa
  Date: 30 oct 2011
 */
void RM_Date::CalcDate() 
{
  double hour, min, sec;
  long int jd12h;
  long int t1, t2, yr, mo;
  int n=0;

  sec=60.;
  while (sec>59.5 && n++<10) {
    hour=(jd+0.5-floor(jd+0.5))*24.; 
    hh=floor(hour); // round to smaller

    min=(hour-floor(hour))*60.;      
    mn=floor(min); // round to smaller
    
    sec=(min-floor(min))*60.;        
    ss=floor(sec+0.5); // round to nearest because there is nothing
                           // smaller than seconds

    // round errors in the math above could lead to seconds between
    // 59.5 and 60.0, which will round up to 60, while it should be 0s
    // +1min
    if (ss==60) jd=jd+0.0001/secinday;
  }

  //d1->jd = jd;
  jd12h = floor(jd+0.5);

  t1 = jd12h + 68569L;
  t2 = 4L * t1 / 146097L;
  t1 = t1 - ( 146097L * t2 + 3L ) / 4L;
  yr = 4000L * ( t1 + 1L ) / 1461001L;
  t1 = t1 - 1461L * yr / 4L + 31L;
  mo = 80L * t1 / 2447L;
  dd = (int) ( t1 - 2447L * mo / 80L );
  t1 = mo / 11L;
  mm = (int) ( mo + 2L - 12L * t1 );
  yy = (int) ( 100L * ( t2 - 49L ) + yr + t1 );
  
  // Correct for BC years
  if ( yy <= 0 )
    yy -= 1;

}

//______________________________________________________________________________
/*
  Function: SecDiff
  Description: current - rhs (in seconds)
  Author: hbarbosa
  Date: 30 oct 2011
 */
int RM_Date::SecDiff(const RM_Date &rhs)
{
  return(floor((jd-rhs.jd)*secinday+0.5));
}

//______________________________________________________________________________
/*
  Function: MinDiff
  Description: current - rhs (in minutes)
  Author: hbarbosa
  Date: 12 Nov 2011
 */
int RM_Date::MinDiff(const RM_Date &rhs)
{
  return(floor((jd-rhs.jd)*mininday+0.5));
}

//______________________________________________________________________________
/*
  Function: HourDiff
  Description: current - rhs (in hours)
  Author: hbarbosa
  Date: 12 Nov 2011
 */
int RM_Date::HourDiff(const RM_Date &rhs)
{
  return(floor((jd-rhs.jd)*hourinday+0.5));
}

//______________________________________________________________________________
/*
  Function: DayDiff
  Description: current - rhs (in days)
  Author: hbarbosa
  Date: 30 oct 2011
 */
int RM_Date::DayDiff(const RM_Date &rhs)
{
  return(floor((jd-rhs.jd))+0.5);
}

