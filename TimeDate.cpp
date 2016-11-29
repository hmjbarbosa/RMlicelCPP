#include "TimeDate.h"
#include <string>
using std::string;

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
  this->yy  = date.yy;
  this->mm  = date.mm;
  this->dd  = date.dd;
  this->hh  = date.hh;
  this->mn  = date.mn;
  this->ss  = date.ss;
  this->jd  = date.jd;
  this->secd= date.secd;
  this->utc = date.utc;
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
                 const float utc)
{
  this->yy = year;
  this->mm = mon;
  this->dd = day;
  this->hh = hour;
  this->mn = min;
  this->ss = sec;
  this->utc = utc;

  //  std::cerr << "antes\n";
  this->CalcJD();
}

//______________________________________________________________________________
/*
  Function: Constructor from JD and UTC
  Description: initialize with a julian date
  Author: hbarbosa
  Date: 12 nov 2011
 */
RM_Date::RM_Date(const double jd, const int secd, const float utc)
{
  this->utc = utc;
  this->jd  = jd;
  this->secd= secd;

  this->CalcDate();
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
  Function: RM_Date operator = 
  Description: 
  Author: hbarbosa
  Date: 12 dec 2011
 */
RM_Date& RM_Date::operator=(const RM_Date &rhs)
{
  if (this != &rhs) {
    yy  = rhs.yy;
    mm  = rhs.mm;
    dd  = rhs.dd;
    hh  = rhs.hh;
    mn  = rhs.mn;
    ss  = rhs.ss;
    jd  = rhs.jd;
    secd= rhs.secd;
    utc = rhs.utc;
  }
  return *this;
}

//______________________________________________________________________________
/*
  Function: Nullify
  Description: initialize date with -999
  Author: hbarbosa
  Date: 12 nov 2011
*/
void RM_Date::Nullify()
{
  yy  = -999;
  mm  = -999;
  dd  = -999;
  hh  = -999;
  mn  = -999;
  ss  = -999;
  jd  = -999.;
  secd= -999;
  utc = -999.;
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
  /*
  std::cerr<< this->write2nc() <<std::endl;
  printf("%17.8f\n",jd);
  printf("%17.8f\n",             secd*1.);
  printf("%17.8f\n",             secd/double(secinmin));
  printf("%17.8f\n",             secd/double(secinmin)+double(0.5));
  printf("%17.8f\n",       floor(secd/double(secinmin)+double(0.5)));
  printf("%17.8f\n",double(floor(secd/double(secinmin)+double(0.5))));
  printf("%17.8f\n",double(floor(secd/double(secinmin)+double(0.5)))*double(secinmin));
  */
  secd = double(floor(secd/double(secinmin)+0.5))*double(secinmin);
  // it is always in the same day, except if it rounds up to 24hs
  if (secd>=secinday) { secd-=secinday; jd+=1; }

  CalcDate();

  //std::cerr<< this->write2nc() <<std::endl;

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
  char strdate[27];
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
  char strdate[11];
  sprintf(strdate,"%04d%1c%02d%1c%02d", yy,sep, mm,sep, dd);
  return(strdate);
}
std::string RM_Date::write2DMY(const char sep) 
{
  char strdate[11];
  //std::cerr << "aqui w " << dd << sep << mm << sep << yy << "\n";
  //std::cerr << "|" << yy << "|\n";
  //std::cerr << "|" << printf(" %d %c %d ; %c ; %d ; ", dd,sep, mm,sep,yy) << "|" << yy << std::endl;
  sprintf(strdate,"%02d%1c%02d%1c%04d", dd,sep, mm,sep, yy);
  //std::cerr << "aqui w 1a\n";
  //std::string str(strdate);
  //return(str);
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
  char strdate[9];
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

//   double 
//     hour = hh+(mn+(ss/60.))/60.;

   long int
     lday   = (long) dd,
     lmonth = (long) mm,
     lyear  = (long) yy;
   //std::cerr << "lyear = " << lyear << std::endl;

   secd = hh*secinhour+mn*secinmin+ss;

   // Adjust BC years
   if ( lyear < 0 ) lyear++;
   
   jd12h = lday - 32075L + 
     1461L * (lyear + 4800L + (lmonth - 14L) / 12L) / 4L +
     367L * (lmonth - 2L - (lmonth - 14L) / 12L * 12L) / 12L - 
     3L * ((lyear + 4900L + (lmonth - 14L) / 12L) / 100L) / 4L;

   // julian day is integer at noon (half day through)
   // hmjb: we subtract - 0.5 so that it starts at midnight (??? need check)
   jd = (double) jd12h - 0.5 + double(secd) / double(secinday);
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
//  int n=0;
//
//  sec=60.;
//  while (sec>59.5 && n++<10) {
//    hour=(jd+0.5-floor(jd+0.5))*24.; 
//    hh=floor(hour); // round to smaller
//
//    min=(hour-floor(hour))*60.;      
//    mn=floor(min); // round to smaller
//    
//    sec=(min-floor(min))*60.;        
//    ss=floor(sec+0.5); // round to nearest because there is nothing
//                           // smaller than seconds
//
//    // round errors in the math above could lead to seconds between
//    // 59.5 and 60.0, which will round up to 60, while it should be 0s
//    // +1min
//    if (ss==60) jd=jd+0.0001/secinday;
//  }

  // correct for fractional day outside range [0, 0)
  while(secd>=secinday) { secd-=secinday; jd+=1; }
  while(secd<0.)        { secd+=secinday; jd-=1; }

  // get hms from seconds in day
  sec=double(secd);                        ss=floor( fmod(sec,  (double) secinmin)  +0.5);
  min=(sec-double(ss))/double(secinmin);   mn=floor( fmod(min,  (double) mininhour) +0.5);
  hour=(min-double(mn))/double(mininhour); hh=floor( fmod(hour, (double) hourinday) +0.5);

  //printf("sec= %27.18f min=%27.18f hour=%27.18f\n",sec,min,hour);
  //printf("ss= %d %d %d\n",ss, mn, hh);

  //d1->jd = jd;
  jd12h = floor(jd + 0.5 - double(secd)/double(secinday));

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
  return(floor((jd-rhs.jd)*secinday+(secd-rhs.secd)+0.5));
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
  return(floor((jd-rhs.jd)*mininday+(secd-rhs.secd)/secinmin+0.5));
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
  return(floor((jd-rhs.jd)*hourinday+(secd-rhs.secd)/secinhour+0.5));
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
  return(floor((jd-rhs.jd)+(secd-rhs.secd)/secinday+0.5));
}

