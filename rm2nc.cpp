#include "RMnetcdfUSP.h"

/*
  PROGRAM: rm2nc
  AUTHOR: hbarbosa
  DATE: 8 October, 2011

  USE:
     rm2nc <file1> [<file2> ... ]

  INTENT:
     Convert a list of binary Raymetrics/Licel files into netcdf
     files. New files are named by adding a ".nc" after each file's
     name. Data are converted to physical units. netCDF complies with
     COARDS conventions besides including fields such as contact and
     history. The output format could be used easily with standard
     scientific software such as grads, matlab, etc.

 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX;
  char fnc[256];
  int err;
  
  if (argc<2) {
    printf("Enter a file name!\n");
    return 1;
  }
  
  for (int i=1; i<argc; i++) {
    // Init, Read, Print some data 
    Init_RMDataFile(&XX);
    err=profile_read(argv[i], &XX, false);

    // Write netcdf
    if (!err) {
      //sprintf(fnc,"RM_%s_%02dh%02d.nc",XX.end.write2YMD('_').c_str(), 
      //        XX.end.GetHour(), XX.end.GetMin());
      sprintf(fnc,"%s.nc",argv[i]);

      profile_write_netcdf(fnc, XX);
    }

    // destroy RM data file
    Free_RMDataFile(&XX);
  }

  return 0;
}
