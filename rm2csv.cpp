#include "RMlicel.h"

/*
  PROGRAM: rm2csv
  AUTHOR: hbarbosa
  DATE: May, 2011

  USE:
     rm2csv <file1> [<file2> ... ]

  INTENT:
     Convert a list of binary Raymetrics/Licel files into ASCII
     files. New files are named by adding a ".csv" after each file's
     name. Data are converted to physical units. All numbers are
     separated by ";" to be read into a spreadsheet program as a
     comma-separated-values (CSV) file.
 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX;
  FILE *fout;
  char fcsv[256];
  
  if (argc<2) {
    printf("Enter a file name!\n");
    return 1;
  }
  
  for (int i=1; i<argc; i++) {
    // Open output file
    snprintf(fcsv,256,"%s.csv",argv[i]);
    fout=fopen(fcsv,"w");

    // Init, Read, Print and destroy RM data file
    Init_RMDataFile(&XX);
    profile_read(argv[i], &XX);
    profile_printf(fout, XX, 0, "", " ; ", " ; ");
    Free_RMDataFile(&XX);

    // Close output file
    fclose(fout);
  }

  return 0;
}
