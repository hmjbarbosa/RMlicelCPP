/* TimeDate.h -- Simple time and date routines.
 */
#ifndef _TIMEDATE_H
#define _TIMEDATE_H

#include <stdlib.h> /* int32_t */
#include <stdio.h> /* all file IO stuff */
#include <math.h>
#include "iomanip" 

#include "iostream"

#define secinday 86400
#define mininday 1440
#define hourinday 24
#define secinhour 3600
#define secinmin 60
#define mininhour 60
#define jd2010 2455197.5
#define jd1900 2415020.5

class RM_Date {

 private:
  int yy;
  int mm;
  int dd;
  int hh;
  int mn;
  int ss;
  double jd; // julian day
  int secd; // seconds in day (starts at 0:00)
  float utc;

  // calculate jd from the value date
  void CalcJD();
  // calculate date from the jd
  void CalcDate();

 public:

  // default
  RM_Date();
  // initialize with an object
  RM_Date(const RM_Date &date);
  // initialize with a date
  RM_Date(const int year, const int mon, const int day,
          const int hour, const int min, const int sec,
          const float utc);
  // initialize with a julian day + seconds in day
  RM_Date(const double jd, const int secd, const float utc);

  // destructor
  ~RM_Date();
  
  // operator overloading
  RM_Date &operator=(const RM_Date &rhs);
  bool operator< (const RM_Date &rhs) { return(RM_Date::jd <  rhs.jd); };
  bool operator> (const RM_Date &rhs) { return(RM_Date::jd >  rhs.jd); };
  bool operator<=(const RM_Date &rhs) { return(RM_Date::jd <= rhs.jd); };
  bool operator>=(const RM_Date &rhs) { return(RM_Date::jd >= rhs.jd); };
  bool operator==(const RM_Date &rhs) { return(RM_Date::jd == rhs.jd); };

  // get functions
  int GetYear()   { return (RM_Date::yy);  };
  int GetMonth()  { return (RM_Date::mm);  };
  int GetDay()    { return (RM_Date::dd);  };
  int GetHour()   { return (RM_Date::hh);  };
  int GetMin()    { return (RM_Date::mn);  };
  int GetSec()    { return (RM_Date::ss);  };
  float GetUTC()  { return (RM_Date::utc); };
  double GetJD()  { return (RM_Date::jd);  };

  // get functions
  void SetYear (const int Year ) { RM_Date::yy=Year ; CalcJD(); };
  void SetMonth(const int Month) { RM_Date::mm=Month; CalcJD(); };
  void SetDay  (const int Day  ) { RM_Date::dd=Day  ; CalcJD(); };
  void SetHour (const int Hour ) { RM_Date::hh=Hour ; CalcJD(); };
  void SetMin  (const int Min  ) { RM_Date::mn=Min  ; CalcJD(); };
  void SetSec  (const int Sec  ) { RM_Date::ss=Sec  ; CalcJD(); };
  void SetJD   (const double JD) { RM_Date::jd=JD   ; CalcDate(); };

  // initialize date with -999
  void Nullify();

  // round date d1 to the nearest full minute and save it to d2
  void RoundMinutes(); 

  // write date/time in netcdf format
  // YYYY-MM-DD hh:mm:ss UTC
  std::string write2nc();

  // date to string
  std::string write2YMD(const char sep='/');
  std::string write2DMY(const char sep='/');

  // time to string
  std::string write2hms(const char sep=':'); 

  // time difference between two dates
  int SecDiff (const RM_Date &rhs);
  int MinDiff (const RM_Date &rhs);
  int HourDiff(const RM_Date &rhs);
  int DayDiff (const RM_Date &rhs);
};

#endif /* _TIMEDATE_H */
