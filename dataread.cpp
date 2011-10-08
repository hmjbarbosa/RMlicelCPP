#include "RMlicelUSP.h"

/*
  PROGRAM: licel data read
  AUTHOR: hbarbosa
  DATE: May, 2011
 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX;

  if (argc<2) {
    printf("Enter a file name!\n");
    return 1;
  }
  for (int i=1; i<argc; i++) {
    Init_RMDataFile(&XX);
    profile_read(argv[i], &XX);
    profile_printf(stdout, XX, 10, ";", ";", ";");
    Free_RMDataFile(&XX);
  }

  return 0;
}
