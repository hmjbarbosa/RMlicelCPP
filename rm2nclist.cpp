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
  RMDataFile *RMFirst, *RMToAdd;
  RM_Date LastDate;
  char fdat[256];
  int tdif;

  if (argc<3) {
    printf("Usage: \n");
    printf(" %s <outfile>  <infile1> [<infile2> ... ]\n",argv[0]);
    return 1;
  }

  RMFirst = (RMDataFile*) malloc(sizeof(RMDataFile));
  // Init variable and read first file
  Init_RMDataFile(RMFirst);
  profile_read(argv[2], RMFirst);
  // Init NC file and write first data
  sprintf(fdat,"%s.nc",argv[1]);
  profile_write_netcdf(fdat, *RMFirst, 0);
  // Copy previous date
  LastDate = RMFirst->end;
  
  // Other files 
  RMToAdd = (RMDataFile*) malloc(sizeof(RMDataFile));
  for (int i=3; i<argc; i++) {

    // Read other files 
    Init_RMDataFile(RMToAdd);
    profile_read(argv[i], RMToAdd);

    // check time order
    tdif=RMToAdd->end.SecDiff(LastDate);
    std::cerr << tdif << "\n";
    if (tdif<0) {
      std::cerr << "ERROR: Files must be in chronological order!\n\n";
      exit(1);
    }

    // re-open netcdf and add a new profile
    profile_add_netcdf(fdat, *RMFirst, *RMToAdd);
    // Copy previous date
    LastDate = RMToAdd->end;

    // Release memory
    Free_RMDataFile(RMToAdd);
  }

  // Release memory
  Free_RMDataFile(RMFirst);
  free(RMFirst);
  free(RMToAdd);
  

  return 0;
}
