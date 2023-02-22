#include "RMlicel.h"
//#include "TimeDate.h"
#include <unistd.h>

/*
  PROGRAM: rm2bin
  AUTHOR: hbarbosa
  DATE: May, 2011

  USE:
     rm2nc <output> <file1> [<file2> ... ]

  INTENT:
     Adds a list of files and save the result in a binary
     Raymetrics/Licel file. The new file must not exist. Raw data and
     number of shoots are accumulated; T0 and P0 are averaged; start
     and end dates are set to be the earliest and latest amongst all
     files respectively, hence covering the whole period. All other
     variables, e.g. altitude, repetition rate, channel configuration,
     must be the same in all files.

 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX, XAve;
  FILE *fout;
  char filename[256];

  // check number of arguments
  if (argc<3) {
    printf("Usage: \n");
    printf(" %s <output file> <list of input RM files>\n",argv[0]);
    return 1;
  }

  // check output file
  strcpy(filename, argv[1]);
  if (!access(filename, F_OK)) {
    printf("Output file should not exist!\n");
    return 1;
  }

  // Loop over files to add
  for (int i=2; i<argc; i++) {

    if (i==2) {
      // Init average variable and read first file
      Init_RMDataFile(&XAve);
      profile_read(argv[i], &XAve);
    } else {
      printf("nao era para entrar aqui... \n");
      // Read other files into temporary variable
      Init_RMDataFile(&XX);
      profile_read(argv[i], &XX);

      // Add to average variable
      profile_add(&XAve, XX);

      // Release memory
      Free_RMDataFile(&XX);
    }
  }

  // Open output file
  fout=fopen(filename,"w");
  if (fout==NULL) {
    perror("Failed to open output file");
    exit(1);
  }

  printf("%f\n", XAve.ch[0].phy[0]);
  printf("%f\n", XAve.ch[0].phy[1]);
  printf("%f\n", XAve.ch[0].phy[2]);

  // Write averaged data
  profile_write(fout, XAve);

  // Close output file
  fclose(fout);
  Free_RMDataFile(&XAve);
  printf("saiu do rm2bin ====\n");
    
  return 0;
}
