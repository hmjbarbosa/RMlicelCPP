#include "RMnetcdfUSP.h"
#include <iomanip>

/*
  PROGRAM: licel data read
  AUTHOR: hbarbosa
  DATE: May, 2011

  USE:
     rm2nclist <output> <file1> [<file2> ... ]

  INTENT:
     Convert a list of binary Raymetrics/Licel files into a single
     netcdf file. The new file will be <output>.nc. Data are converted
     to physical units. netCDF complies with COARDS conventions
     besides including fields such as contact and history. The output
     format could be used easily with standard scientific software
     such as grads, matlab, etc.
 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX1, XX;

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
      Init_RMDataFile(&XX1);
      profile_read(argv[i], &XX1);
      // Init NC file and write first data
      profile_write_netcdf(argv[1], XX1);

    } else {
      // Read other files 
      Init_RMDataFile(&XX);
      profile_read(argv[i], &XX);
      // re-open netcdf and add a new profile
      profile_add_netcdf(argv[1], XX1, XX);
      // Release memory
      Free_RMDataFile(&XX);
    }
  }

  // Release memory
  Free_RMDataFile(&XX1);

  return 0;
}
