#include "RMlicelUSP.h"

void Free_RMDataFile(RMDataFile *rm) 
{
  if (rm->ch!=NULL) {
    for (int i=0; i<rm->nch; i++) {
      free(rm->ch[i].raw);
      free(rm->ch[i].phy);
    }
    free(rm->ch);
  } else {
    fprintf(stderr,"ERROR: trying to deallocate a NULL structure!\n");
    exit(1);
  }
}

void Init_RMDataFile(RMDataFile *rm) 
{
  strcpy(rm->file,"-999");
  strcpy(rm->site,"-999");
  rm->start.YY=-999;
  rm->start.MM=-999;
  rm->start.DD=-999;
  rm->start.hh=-999;
  rm->start.mn=-999;
  rm->start.ss=-999;
  rm->end.YY=-999;
  rm->end.MM=-999;
  rm->end.DD=-999;
  rm->end.hh=-999;
  rm->end.mn=-999;
  rm->end.ss=-999;
  rm->alt=-999;
  rm->lon=-999.;
  rm->lat=-999.;
  rm->zen=-999;
  rm->idum=-999;
  rm->T0=-999.;
  rm->P0=-999.;
  rm->nshoots=-999;
  rm->nhz=-999;
  rm->nshoots2=-999;
  rm->nhz2=-999;
  rm->nch=-999;
  rm->ch=NULL;
};

/*
  Function: Read Channel Line
  Description: reads one line of channel info from stream
  Author: hbarbosa
  Date: 30 may 2011
 */
void channel_read(FILE *fp, channel *ch) 
{
  fscanf(fp,"%1d",&ch->active); 
  fscanf(fp,"%1d",&ch->photons);
  fscanf(fp,"%1d",&ch->elastic);
  fscanf(fp,"%5d 1",&ch->ndata);
  fscanf(fp,"%4d",&ch->pmtv);
  fscanf(fp,"%4f",&ch->binw);
  fscanf(fp,"%5d.%1c 0 0 00 000 ",&ch->wlen,&ch->pol); 
  fscanf(fp,"%2d",&ch->bits); 
  fscanf(fp,"%6d",&ch->nshoots); 
  fscanf(fp,"%6f",&ch->discr);
  fscanf(fp,"%3s\n",ch->tr);
}

/*
  Function: Print Channel Line
  Description: prints one line of channel info into stream exactly as read
  Author: hbarbosa
  Date: 30 may 2011
 */
void channel_printf(FILE *fp, channel ch, const char* beg, const char* sep) 
{
  fprintf(fp,"%1s",beg);
  fprintf(fp,"%1d%1s",ch.active,sep);
  fprintf(fp,"%1d%1s",ch.photons,sep); 
  fprintf(fp,"%1d%1s",ch.elastic,sep);
  fprintf(fp,"%05d%1s",ch.ndata,sep);
  fprintf(fp,"%1d%1s",1,sep);
  fprintf(fp,"%04d%1s",ch.pmtv,sep);
  fprintf(fp,"%04.2f%1s",ch.binw,sep);
  fprintf(fp,"%05d.%1c%1s",ch.wlen,ch.pol,sep);
  fprintf(fp,"%1d%1s",0,sep);
  fprintf(fp,"%1d%1s",0,sep);
  fprintf(fp,"%02d%1s",0,sep);
  fprintf(fp,"%03d%1s",0,sep); 
  fprintf(fp,"%02d%1s",ch.bits,sep);
  fprintf(fp,"%06d%1s",ch.nshoots,sep);
  if (!ch.photons)
    fprintf(fp,"%05.3f%1s",ch.discr,sep);
  else
    fprintf(fp,"%06.4f%1s",ch.discr,sep);

  fprintf(fp,"%3s%1s",ch.tr,sep);
  fprintf(fp,"\n");
}

/*
  Function: Print Channel Line for debug purposes
  Description: prints one line of channel info into stream exactly for user reading
  Author: hbarbosa
  Date: 30 may 2011
 */
void channel_debug(channel ch)
{
  fprintf(stderr,"--- Channel: %s \n", ch.tr);
  fprintf(stderr,"active (1/0)= %d\n",ch.active);
  fprintf(stderr,"photon counting (1/0)= %d\n",ch.photons);
  fprintf(stderr,"elastic (1/2)= %d\n",ch.elastic);
  fprintf(stderr,"ndata= %d\n",ch.ndata);
  fprintf(stderr,"pmt voltage (V)= %d\n",ch.pmtv);
  fprintf(stderr,"bin width (m)= %f\n",ch.binw);
  fprintf(stderr,"wavelenght(nm)= %d\n",ch.wlen);
  fprintf(stderr,"polarization= %c\n",ch.pol);
  if (!ch.photons) fprintf(stderr,"bits= %d\n",ch.bits);
  fprintf(stderr,"nshoots= %d\n",ch.nshoots);
  if (!ch.photons) fprintf(stderr,"discr= %f\n",ch.discr);
}

/*
  Function: Read header Line
  Description: reads 3 lines of header info from stream
  Author: hbarbosa
  Date: 17 Aug 2011
 */
void header_read(FILE *fp, RMDataFile *rm) 
{
  char lat[6];
  char lon[6];
  char T0[4];
  char P0[6];  

  // Line 1
  fscanf(fp,"%13s\n", rm->file);
  
  // Line 2
  fscanf(fp,"%s",rm->site);
  fscanf(fp,"%2d/%2d/%4d",&rm->start.DD,&rm->start.MM,&rm->start.YY);
  fscanf(fp,"%2d:%2d:%2d",&rm->start.hh,&rm->start.mn,&rm->start.ss);
  fscanf(fp,"%2d/%2d/%4d",&rm->end.DD,  &rm->end.MM,  &rm->end.YY);
  fscanf(fp,"%2d:%2d:%2d",&rm->end.hh,  &rm->end.mn,  &rm->end.ss);
  fscanf(fp,"%d",&rm->alt);
  fscanf(fp,"%s",lon);
  fscanf(fp,"%s",lat);
  fscanf(fp,"%d", &rm->zen);
  fscanf(fp,"%d",&rm->idum);
  fscanf(fp,"%s",T0);
  fscanf(fp,"%s",P0);
  fscanf(fp,"\n");

  // Depending on windows configuration, data file may have numbers
  // separated by comma instead of dot
  for (int i=0; i<6; i++) {
    if (lat[i]==',') lat[i]='.';
    if (lon[i]==',') lon[i]='.';
    if (P0[i]==',') P0[i]='.';
  }
  for (int i=0; i<4; i++) {
    if (T0[i]==',') T0[i]='.';
  }
  rm->lon=atof(lon);
  rm->lat=atof(lat);
  rm->T0=atof(T0);
  rm->P0=atof(P0);

  // Line 3
  fscanf(fp,"%7d %4d %7d %4d %2d\n",
         &rm->nshoots, &rm->nhz, &rm->nshoots2, &rm->nhz2,&rm->nch);
}

/*
  Function: Print header Line
  Description: prints 3 lines of header info into stream exactly as read
  Author: hbarbosa
  Date: 30 may 2011
 */
void header_printf(FILE *fp, RMDataFile rm, const char* beg, const char* sep) 
{
  // line 1
  fprintf(fp,"%1s",beg);
  fprintf(fp,"%13s%1s",rm.file,sep);
  fprintf(fp,"\n");
  
  // Line 2
  fprintf(fp,"%1s",beg);
  fprintf(fp,"%s%1s",rm.site,sep);
  fprintf(fp,"%02d/%02d/%04d%1s",rm.start.DD,rm.start.MM,rm.start.YY,sep);
  fprintf(fp,"%02d:%02d:%02d%1s",rm.start.hh,rm.start.mn,rm.start.ss,sep);
  fprintf(fp,"%02d/%02d/%04d%1s",rm.end.DD,rm.end.MM,rm.end.YY,sep);
  fprintf(fp,"%02d:%02d:%02d%1s",rm.end.hh,rm.end.mn,rm.end.ss,sep);
  fprintf(fp,"%04d%1s",rm.alt,sep);
  fprintf(fp,"%06.1f%1s",rm.lon,sep);
  fprintf(fp,"%06.1f%1s",rm.lat,sep);
  fprintf(fp,"%02d%1s",rm.zen,sep);
  fprintf(fp,"%02d%1s",rm.idum,sep);
  fprintf(fp,"%4.1f%1s",rm.T0,sep);
  fprintf(fp,"%6.1f%1s",rm.P0,sep);
  fprintf(fp,"\n");

  // Line 3
  fprintf(fp,"%1s",beg);
  fprintf(fp,"%07d%1s",rm.nshoots,sep);
  fprintf(fp,"%04d%1s",rm.nhz,sep);
  fprintf(fp,"%07d%1s",rm.nshoots2,sep);
  fprintf(fp,"%04d%1s",rm.nhz2,sep);
  fprintf(fp,"%02d%1s",rm.nch,sep);
  fprintf(fp,"\n");
}

/*
  Function: Print header Line for debug purposes
  Description: prints 3 lines of header info into stream exactly for user reading
  Author: hbarbosa
  Date: 30 may 2011
 */
void header_debug(RMDataFile rm) 
{
  fprintf(stderr,"====== FILE: %s %s\n",rm.file, rm.site);
  fprintf(stderr,"start: %02d/%02d/%02d %02d:%02d:%02d\n",
          rm.start.DD, rm.start.MM, rm.start.YY, rm.start.hh, rm.start.mn, rm.start.ss);
  fprintf(stderr,"end: %02d/%02d/%02d %02d:%02d:%02d\n",
          rm.end.DD, rm.end.MM, rm.end.YY, rm.end.hh, rm.end.mn, rm.end.ss);
  fprintf(stderr,"altitude (m): %d\n",rm.alt);
  fprintf(stderr,"position (lat/lon): %f %f\n",rm.lat,rm.lon);
  fprintf(stderr,"zenith: %d \n",rm.zen);
  fprintf(stderr,"Reference temperature (C): %f \n",rm.T0);
  fprintf(stderr,"Reference pressure (mb): %f \n",rm.P0);
  fprintf(stderr,"Num. of shoots= %d\n", rm.nshoots);
  fprintf(stderr,"repetition rate= %d\n", rm.nhz);
  fprintf(stderr,"Num. of channels= %d\n", rm.nch);
}

int file_error(FILE *filep)
{
  /*Error detection */
  if( ferror( filep) != 0) {
    fflush(NULL);
    /* really an error happens */
    perror("");
    clearerr(filep);
    return -2;
  }
  else {
    if( feof( filep) != 0) {
	     fflush( NULL);
	     fprintf( stderr, "\nEND OF FILE detected");
	     return( -1);
    }
  }
  return 0;
}

void raw_write(FILE *fp, RMDataFile rm) 
{
  int ierr;

  // for each channel
  for (int i=0; i<rm.nch; i++) { 
    ierr=fwrite(rm.ch[i].raw, sizeof(bin), rm.ch[i].ndata, fp);

    if(ierr!=rm.ch[i].ndata) {
      fprintf(stderr,"\nwrite block %d corrupt",i+1);
      exit(0);
    }
  }
}

void raw_printf(FILE *fp, RMDataFile rm, int imax, const char* sep) 
{

  int ndata[rm.nch];
  int nmax = 0;

  // get the number of bins in each channel
  // in a weird configuration these could be different
  for (int i=0; i<rm.nch; i++) {
    ndata[i] = rm.ch[i].ndata;
    if (ndata[i]>nmax) nmax=ndata[i];
  }
  if (imax!=0 && nmax>imax) nmax=imax;

  // print at most nmax bins
  for (int k=0; k<nmax; k++) {
    fprintf(fp,"%5d",k);
    // for each channel
    for (int i=0; i<rm.nch; i++) { 
      if (k<ndata[i])
        fprintf(fp,"%1s%8d",sep,rm.ch[i].raw[k]);
      else
        fprintf(fp,"%1sx",sep);
    }
    fprintf(fp,"\n"); 
  }
}

void raw_debug(RMDataFile rm, int imax) 
{

  int ndata[rm.nch];
  int nmax = 0;

  // get the number of bins in each channel
  // in a weird configuration these could be different
  for (int i=0; i<rm.nch; i++) {
    ndata[i] = rm.ch[i].ndata;
    if (ndata[i]>nmax) nmax=ndata[i];
  }
  if (imax!=0 && nmax>imax) nmax=imax;

  // print at most nmax bins
  for (int k=0; k<nmax; k++) {
    fprintf(stderr,"bin=%d",k);
    // for each channel
    for (int i=0; i<rm.nch; i++) { 
      if (k<ndata[i])
        fprintf(stderr,"\t%d",rm.ch[i].raw[k]);
      else
        fprintf(stderr,"\tx");
    }
    fprintf(stderr,"\n"); 
  }
}

void phy_printf(FILE *fp, RMDataFile rm, int imax, const char* sep) 
{

  int ndata[rm.nch];
  int nmax = 0;

  // get the number of bins in each channel
  // in a weird configuration these could be different
  for (int i=0; i<rm.nch; i++) {
    ndata[i] = rm.ch[i].ndata;
    if (ndata[i]>nmax) nmax=ndata[i];
  }
  if (imax!=0 && nmax>imax) nmax=imax;

  // print at most nmax bins
  for (int k=0; k<nmax; k++) {
    fprintf(fp,"%5d",k);
    // for each channel
    for (int i=0; i<rm.nch; i++) { 
      if (k<ndata[i])
        fprintf(fp,"%1s%8.4f",sep,rm.ch[i].phy[k]);
      else
        fprintf(fp,"%1s%8.4f",sep,-999.);
    }
    fprintf(fp,"\n"); 
  }
}

void phy_debug(RMDataFile rm, int imax) 
{

  int ndata[rm.nch];
  int nmax = 0;

  // get the number of bins in each channel
  // in a weird configuration these could be different
  for (int i=0; i<rm.nch; i++) {
    ndata[i] = rm.ch[i].ndata;
    if (ndata[i]>nmax) nmax=ndata[i];
  }
  if (imax!=0 && nmax>imax) nmax=imax;

  // print at most nmax bins
  for (int k=0; k<nmax; k++) {
    fprintf(stderr,"bin=%d",k);
    // for each channel
    for (int i=0; i<rm.nch; i++) { 
      if (k<ndata[i])
        fprintf(stderr,"\t%g",rm.ch[i].phy[k]);
      else
        fprintf(stderr,"\t%g",-999.);
    }
    fprintf(stderr,"\n"); 
  }
}

/*
  Function: read_single_file
  Description: read one lidar file and store all data inside a RMDataFile variable
  Author: hbarbosa
  Date: 17 Aug 2011
 */
void profile_read (const char* fname, RMDataFile *rm) 
{
  FILE *fp; // file pointer
  int nread; // amount of data read
  float dScale; // conversion between raw and physical data
  char szBuffer[90]; // dummy buffer
  
  Init_RMDataFile(rm);
  
  // OPEN DATA FILE
  fp=fopen(fname,"r");

  // READ THE FIRST 3 LINES
  header_read(fp, rm);

  // ALLOCATE MEMORY FOR HOLDING CHANNELS
  rm->ch=(channel*) malloc(rm->nch*sizeof(channel));
  
  // READ LINES DESCRIBING CHANNELS
  for (int i=0; i<rm->nch; i++) {
    channel_read(fp, &rm->ch[i]);
  }

  // READ ACTUAL DATA (IN BINARY FORMAT)
  for (int i=0; i<rm->nch; i++) {
    if (rm->ch[i].active!=0) {
      rm->ch[i].raw = (bin *) malloc(sizeof(bin)*rm->ch[i].ndata);
      rm->ch[i].phy = (float *) malloc(sizeof(float)*rm->ch[i].ndata);
      
      // read from file and check amount of data read
      nread=fread(rm->ch[i].raw,sizeof(bin),rm->ch[i].ndata,fp);
      if(nread<(sizeof(bin)*rm->ch[i].ndata)) {
        if(file_error(fp)!=0) {
          fprintf(stderr,"\nblock %d corrupt",i+1);
          exit(0);
        }
      }
      // convert data to physical units
      if (!rm->ch[i].photons)
        dScale = rm->ch[i].nshoots*pow(2,rm->ch[i].bits)/
          (rm->ch[i].discr*1.e3);
      else 
        dScale = rm->ch[i].nshoots/20.;
      
      for (int j=0; j<rm->ch[i].ndata; j++) 
        rm->ch[i].phy[j] = (float) rm->ch[i].raw[j] / dScale;

      // read end of line
      if(fgets(szBuffer,90,fp)==NULL) {
        if(file_error(fp)!=0) {
          fprintf(stderr,"\nmarker %d corrupt",i+1);
          exit(0);
        }
      }

    }// is chanel active?
  }// chanel read
}

void profile_debug(RMDataFile rm) 
{
  // Print main header
  header_debug(rm);
  
  // Print lines describing channels
  for (int i=0; i<rm.nch; i++) {
    channel_debug(rm.ch[i]);
  }

  // Print bin data
  raw_debug(rm, 0);
  phy_debug(rm, 0);
}

void profile_printf(FILE *fp, RMDataFile rm, int imax, const char* beg, 
                    const char* sep, const char* sep2) 
{  
  // Print main header
  header_printf(fp, rm, beg, sep);
  
  // Print lines describing channels
  for (int i=0; i<rm.nch; i++) {
    channel_printf(fp, rm.ch[i], beg, sep);
  }

  // Print bin data
  phy_printf(fp, rm, imax, sep2);
}

void profile_write(FILE *fp, RMDataFile rm) 
{  
  // Print main header
  header_printf(fp, rm, "", "");
  
  // Print lines describing channels
  for (int i=0; i<rm.nch; i++) {
    channel_printf(fp, rm.ch[i], "", "");
  }

  // Print bin data
  raw_write(fp, rm);
}
