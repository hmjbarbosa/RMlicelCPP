#include "RMlicelUSP.h"
#include "TimeDate.h"
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
//  RM_Date tmp;
//  double xx;
//
//  tmp = RM_Date(2014,2,1,0,0,0, -4);
//  xx=tmp.GetJD();
//  std::cerr << tmp.write2YMD() << '\n';
//  std::cerr << tmp.write2hms() << '\n';
//  std::cerr << tmp.GetJD()-2.4566e6 << '\n';
//  std::cerr << tmp.GetSecD() << '\n';
//
//  tmp = RM_Date(2014,2,1,11,59,0, -4);
//  xx=tmp.GetJD();
//  std::cerr << tmp.write2YMD() << '\n';
//  std::cerr << tmp.write2hms() << '\n';
//  std::cerr << tmp.GetJD()-2.4566e6 << '\n';
//  std::cerr << tmp.GetSecD() << '\n';
//
//  tmp = RM_Date(2014,2,1,12,0,0, -4);
//  xx=tmp.GetJD();
//  std::cerr << tmp.write2YMD() << '\n';
//  std::cerr << tmp.write2hms() << '\n';
//  std::cerr << tmp.GetJD()-2.4566e6 << '\n';
//  std::cerr << tmp.GetSecD() << '\n';
//
//  return 0;

  if (argc<3) {
    printf("Usage: \n");
    printf(" %s <output file> <list of input files>\n",argv[0]);
    return 1;
  }

  if (!access(argv[1], F_OK)) {
    printf("Output file should not exist!\n");
    return 1;
  }

  // Files to add
  for (int i=2; i<argc; i++) {

    if (i==2) {
      // Init average variable and read first file
      Init_RMDataFile(&XAve);
      profile_read(argv[i], &XAve);
    } else {
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
  fout=fopen(argv[1],"w");
  if (fout==NULL) {
    perror("Failed to open output file");
    exit(1);
  }

  // Write averaged data
  profile_write(fout, XAve);

  // Close output file
  fclose(fout);

  Free_RMDataFile(&XAve);

  return 0;
}
