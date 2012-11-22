#include "RMlicelUSP.h"
#include <unistd.h>

/*
  PROGRAM: rm2bin
  AUTHOR: hbarbosa
  DATE: May, 2011
 */
int main (int argc, char *argv[]) 
{
  RMDataFile XX, XAve;
  FILE *fout;
  
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
