#include "RMlicel.h"

/*
  PROGRAM: rm2dat
  AUTHOR: hbarbosa
  DATE: May, 2011

  USE:
     rm2dat <file1> [<file2> ... ]

  INTENT:
     Convert a list of binary Raymetrics/Licel files into ASCII
     files. New files are named by adding a ".dat" after each file's
     name. Data are converted to physical units. A "# " is added to
     each header line and data is separated by tabs. The output format
     could be used easily with standard plotting utilities such as
     gnuplot.

 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX;
  FILE *fout;
  char fdat[256] = "";

  if (argc<2) {
    printf("Enter a file name!\n");
    return 1;
  }
  
  for (int i=1; i<argc; i++) {
    // Open output file
    snprintf(fdat,256,"%s.dat",argv[i]);
    fout=fopen(fdat,"w");

    // Init, Read, Print and destroy RM data file
    Init_RMDataFile(&XX);
    profile_read(argv[i], &XX);
    printf("%f %d \n", XX.ch[0].phy[0], XX.ch[0].raw[0]);
    printf("%f %d \n", XX.ch[0].phy[1], XX.ch[0].raw[1]);
    printf("%f %d \n", XX.ch[0].phy[2], XX.ch[0].raw[2]);

    
    profile_printf(fout, XX, 0, "# ", " ", "\t");

    // Close output file
    Free_RMDataFile(&XX);
    fclose(fout);
    printf("saiu do rm2dat ====\n");    
  }

  return 0;
}
