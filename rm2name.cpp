#include "RMnetcdfUSP.h"
#include <iomanip>

/*
  PROGRAM: licel data read
  AUTHOR: hbarbosa
  DATE: May, 2011
 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX;
  RM_Date last;

  if (access(argv[1], F_OK)) {
    printf("File does not exist!\n");
    return 1;
  }

  Init_RMDataFile(&XX);
  profile_read(argv[1], &XX);

  last=XX.end;
  last.RoundMinutes();
  printf("RM_%s_%02d.%02d",last.write2YMD('-').c_str(),
         last.GetHour(), last.GetMin());

  Free_RMDataFile(&XX);
  return 0;
}
