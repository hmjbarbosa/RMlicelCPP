#include "RMnetcdfUSP.h"

/*
  PROGRAM: rm2nc
  AUTHOR: hbarbosa
  DATE: 8 October, 2011
 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX;
  char fnc[256];
  
  if (argc<2) {
    printf("Enter a file name!\n");
    return 1;
  }
  
  for (int i=1; i<argc; i++) {
    // Open output file
    sprintf(fnc,"%s.nc",argv[i]);

    // Init, Read, Print some data 
    Init_RMDataFile(&XX);
    profile_read(argv[i], &XX);
    profile_printf(stdout, XX, 10, "", " ; ", " ; ");

    // Write netcdf
    profile_write_netcdf(fnc, XX);

    // destroy RM data file
    Free_RMDataFile(&XX);
  }

  return 0;
}
