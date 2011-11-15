#include "RMlicelUSP.h"

/*
  PROGRAM: rm2nc
  AUTHOR: hbarbosa
  DATE: 14 nov 2011
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
    // Open output file
    sprintf(fnc,"%s.nc",argv[i]);

    // Init, Read, Print some data 
    Init_RMDataFile(&XX);
    err=profile_read(argv[i], &XX, true);
    //profile_printf(stdout, XX, 10, "", " ; ", " ; ");

    // destroy RM data file
    Free_RMDataFile(&XX);
  }

  return 0;
}
