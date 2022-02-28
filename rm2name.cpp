#include "RMnetcdf.h"
#include <iomanip>

/*
  PROGRAM: rm2name
  AUTHOR: hbarbosa
  DATE: May, 2011

  USE:
     rm2name <file1> [<file2> ... ]

  INTENT:
     This is a very simple program that reads a list of
     Raymetrics/Licel files and, for each file, print a string to the
     screen with the following format: RM_YYYY-MM-DD_hh:mm. This could
     be used, for example, in a script that will rename the files.

 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX;
  RM_Date last;
  int err;

  if (argc<2) {
    printf("Enter a file name!\n");
    return 1;
  }

  for (int i=1; i<argc; i++) {

    //if (access(argv[1], F_OK)) {
    //  printf("File does not exist!\n");
    //  return 1;
    //}

    // Init, Read, Print some data 
    Init_RMDataFile(&XX);
    err=profile_read(argv[1], &XX);

    // Create string for output
    if (!err) {
      last=XX.end;
      last.RoundMinutes();
      printf("RM_%s_%02d:%02d\n",last.write2YMD('-').c_str(),
	     last.GetHour(), last.GetMin());
    }

    // destroy RM data file
    Free_RMDataFile(&XX);
  }

  return 0;
}
