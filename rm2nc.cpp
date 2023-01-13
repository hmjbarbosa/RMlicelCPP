#include "RMnetcdf.h"

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
  int err, i0=1, tropt=0;
  
  if (argc<2) {
    printf("Usage: \n");
    printf(" %s <file1> [<file2> ... ]\n",argv[0]);

    return 1;
  }
  
  for (int i=i0; i<argc; i++) {
    // Init, Read, Print some data 
    Init_RMDataFile(&XX);
    err=profile_read(argv[i], &XX, false);

    // Write netcdf
    if (!err) {
      snprintf(fnc,256,"%s.nc",argv[i]);

      profile_write_netcdf(fnc, XX, tropt);
    }

    // destroy RM data file
    Free_RMDataFile(&XX);
  }

  return 0;
}
