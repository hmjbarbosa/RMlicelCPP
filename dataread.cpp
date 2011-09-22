//#include <malloc.h>
//#include <stdio.h>
//#include <stdlib.h>
//#include <string.h>
//#include <ctype.h>
//#include <time.h>
//#include <limits.h>
//#include <math.h>
//#include "iostream"

//#include "Char.h"
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

    profile_printf(XX, 10, '#', ' ', '\t');

    Free_RMDataFile(&XX);
  }

  return 0;
}
