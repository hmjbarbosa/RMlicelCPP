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
  double jd;
  float utc;
  
 protected:
  virtual void CalcJD();
  virtual void CalcDate();

 public:

  RM_Date();
  // initialize with an object
  RM_Date(const RM_Date &date);
  // initialize with a date
  RM_Date(const int year, const int mon, const int day,
          const int hour, const int min, const int sec,
          const float futc);
  // initialize with a julian date
  RM_Date(const double julday, const float futc);

  // operator overloading
  RM_Date &operator=(const RM_Date &rhs);
  bool operator<(const RM_Date &rhs);
  bool operator>(const RM_Date &rhs);
  bool operator==(const RM_Date &rhs);

  // destructor
  virtual ~RM_Date();
  
  // plain get functions
  virtual int GetYear();
  virtual int GetMonth();
  virtual int GetDay();
  virtual int GetHour();
  virtual int GetMin();
  virtual int GetSec();
  virtual float GetUTC();
  virtual double GetJD();

  // initialize date with -999
  virtual void Nullify();

  // round date d1 to the nearest full minute and save it to d2
  virtual void RoundMinutes(); 

  // write date/time in netcdf format
  // YYYY-MM-DD hh:mm:ss UTC
  virtual std::string write2nc();

  // date to string
  virtual std::string write2YMD(const char sep='/');
  virtual std::string write2DMY(const char sep='/');

  // time to string
  virtual std::string write2hms(const char sep=':'); 

  // time difference between two dates
  virtual int SecDiff (const RM_Date &rhs);
  virtual int MinDiff (const RM_Date &rhs);
  virtual int HourDiff(const RM_Date &rhs);
  virtual int DayDiff (const RM_Date &rhs);
};

#endif /* _TIMEDATE_H */
