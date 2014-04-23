#include "RMlicelUSP.h"
#include <iostream>
using namespace std;

void Free_RMDataFile(RMDataFile *rm) 
{
  if (rm->ch!=NULL) {
    for (int i=0; i<rm->nch; i++) {
      free(rm->ch[i].raw);
      free(rm->ch[i].phy);
    }
    free(rm->ch);
  }
  rm->start.Nullify();
  rm->end.Nullify();
}

void Init_RMDataFile(RMDataFile *rm) 
{
  strcpy(rm->file,"-999");
  strcpy(rm->site,"-999");
  rm->start.Nullify();
  rm->end.Nullify();
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
void channel_read_error() {
  fprintf(stderr,"fscanf error while reading channel!\n");
  exit(-1);
}

void channel_read(FILE *fp, channel *ch) 
{
  int n;
  n=fscanf(fp,"%d",&ch->active);
  if (n!=1) channel_read_error();
  n=fscanf(fp,"%d",&ch->photons);
  if (n!=1) channel_read_error();
  n=fscanf(fp,"%d",&ch->elastic);
  if (n!=1) channel_read_error();
  n=fscanf(fp,"%d 1",&ch->ndata);
  if (n!=1) channel_read_error();
  n=fscanf(fp,"%d",&ch->pmtv);
  if (n!=1) channel_read_error();
  n=fscanf(fp,"%f",&ch->binw);
  if (n!=1) channel_read_error();
  n=fscanf(fp,"%5d.%1c 0 0 00 000 ",&ch->wlen,&ch->pol); 
  if (n!=2) channel_read_error();
  n=fscanf(fp,"%d",&ch->bits); 
  if (n!=1) channel_read_error();
  n=fscanf(fp,"%d",&ch->nshoots); 
  if (n!=1) channel_read_error();
  n=fscanf(fp,"%f",&ch->discr);
  if (n!=1) channel_read_error();
  n=fscanf(fp,"%s",ch->tr);
  if (n!=1) channel_read_error();

  //n=fscanf(fp,"\r\n");
  n=fscanf(fp,"%*[^\n]"); n=fscanf(fp,"%*c");
  //fprintf(stderr,"fim channel: %ld\n",ftell(fp));
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
  if (!ch.photons) {
    fprintf(fp,"%05.3f%1s",ch.discr,sep);
    fprintf(fp,"%-17s%1s",ch.tr,sep);
  } else {
    fprintf(fp,"%06.4f%1s",ch.discr,sep);
    fprintf(fp,"%-16s%1s",ch.tr,sep);
  }

  fprintf(fp,"\r\n");
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

void channel_debug_phy(channel ch) 
{
  for (int k=0; k<ch.ndata; k++) {
    fprintf(stderr,"bin=%d",k);
    for (int i=k; i<ch.ndata && i<k+20; i++)
      fprintf(stderr," %g",ch.phy[i]);
    k+=19;
    fprintf(stderr,"\n"); 
  }
}

void channel_debug_raw(channel ch) 
{
  for (int k=0; k<ch.ndata; k++) {
    fprintf(stderr,"bin=%d",k);
    for (int i=k; i<ch.ndata && i<k+20; i++)
      fprintf(stderr," %d",ch.raw[i]);
    k+=19; fprintf(stderr,"\n"); 
  }
}

/*
  Function: Read header Line
  Description: reads 3 lines of header info from stream
  Author: hbarbosa
  Date: 17 Aug 2011
 */
void header_read_error() {
  fprintf(stderr,"fscanf error while reading header!\n");
  exit(-1);
}
// RM10C0320.283                                                                
// Manaus 03/12/2010 20:27:30 03/12/2010 20:28:30 0100 -060.0 -003.1 -90 00 30.0 1013.0
// 0000599 0010 0000000 0010 02                                                 
// 1 0 1 16380 1 0990 7.50 00355.o 0 0 00 000 12 000599 0.500 BT0               
// 1 1 1 16380 1 0990 7.50 00355.o 0 0 00 000 00 000599 3.1746 BC0              

void header_read(FILE *fp, RMDataFile *rm, bool debug) 
{
  char lat[6];
  char lon[6];
  char T0[4];
  char P0[6];  
  int n, YY, MM, DD, hh, mn, ss;
  long int pos;
  char tmp[128];
  //double xx;

  // Line 1
  n=fscanf(fp,"%s", rm->file);
  if (n!=1) header_read_error();
  n=fscanf(fp,"%*[^\n]"); n=fscanf(fp,"%*c");
  
  // Line 2
  n=fscanf(fp,"%s",rm->site);
  if (n!=1) header_read_error();
  // some sites might have spaces.
  // keep reading until we find something like ??/??/????
  pos=ftell(fp);
  n=fscanf(fp,"%s",tmp);
  while (strlen(tmp)!=10 || tmp[2]!='/' || tmp[5]!='/') {
    strcat(rm->site, " ");
    strcat(rm->site, tmp);

    pos=ftell(fp);
    n=fscanf(fp,"%s",tmp);
  }
  fseek(fp,pos,SEEK_SET);

  n=fscanf(fp,"%2d/%2d/%4d",&DD,&MM,&YY);
  if (n!=3) header_read_error();
  n=fscanf(fp,"%2d:%2d:%2d",&hh,&mn,&ss);
  if (n!=3) header_read_error();

  rm->start = RM_Date(YY,MM,DD,hh,mn,ss, UTC);
  //xx=rm->start.GetJD();
  //std::cerr << "header_read1= " << rm->start.write2hms() << '\t' << (xx-floor(xx))*1440 << '\n';

  n=fscanf(fp,"%2d/%2d/%4d",&DD,&MM,&YY);
  if (n!=3) header_read_error();
  n=fscanf(fp,"%2d:%2d:%2d",&hh,&mn,&ss);
  if (n!=3) header_read_error();

  rm->end = RM_Date(YY,MM,DD,hh,mn,ss, UTC);
  //xx=rm->end.GetJD();
  //std::cerr << "header_read2= " << rm->end.write2hms() << '\t' << (xx-floor(xx))*1440 << '\n';

  if (n!=3) header_read_error();
  n=fscanf(fp,"%d",&rm->alt);
  if (n!=1) header_read_error();
  n=fscanf(fp,"%s",lon);
  if (n!=1) header_read_error();
  n=fscanf(fp,"%s",lat);
  if (n!=1) header_read_error();

  // Some old Licel does not include 00, T0 and P0 in this line
  // So we need to read the rest of the line, and from that try to
  // read what we want.
  fgets(tmp, sizeof(tmp), fp);
  if (debug) fprintf(stderr,"line=%s\n",tmp);
  n=sscanf(tmp,"%d %d %s %s", &rm->zen, &rm->idum, T0, P0);

  //Because of the fgets() above, the CR+LF are already removed
  //n=fscanf(fp,"%*[^\n]"); n=fscanf(fp,"%*c");

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
  n=fscanf(fp,"%d %d %d %d %d",
           &rm->nshoots, &rm->nhz, &rm->nshoots2, &rm->nhz2, &rm->nch);
  if (n!=5) header_read_error();
  n=fscanf(fp,"%*[^\n]"); n=fscanf(fp,"%*c");

}

/*
  Function: Print header Line
  Description: prints 3 lines of header info into stream exactly as read
  Author: hbarbosa
  Date: 30 may 2011
 */
void header_printf(FILE *fp, RMDataFile rm, 
                   const char* beg, const char* sep) 
{
  // line 1
  fprintf(fp,"%1s",beg);
  fprintf(fp,"%-76s%1s",rm.file,sep);
  fprintf(fp,"\r\n");
  
  // Line 2
  fprintf(fp,"%1s",beg);
  fprintf(fp,"%s%1s",rm.site,sep);
  fprintf(fp,"%s%1s",rm.start.write2DMY('/').c_str(),sep);
  fprintf(fp,"%s%1s",rm.start.write2hms().c_str(),sep);
  fprintf(fp,"%s%1s",rm.end.write2DMY('/').c_str(),sep);
  fprintf(fp,"%s%1s",rm.end.write2hms().c_str(),sep);
  fprintf(fp,"%04d%1s",rm.alt,sep);
  fprintf(fp,"%06.1f%1s",rm.lon,sep);
  fprintf(fp,"%06.1f%1s",rm.lat,sep);
  fprintf(fp,"%02d%1s",rm.zen,sep);
  fprintf(fp,"%02d%1s",rm.idum,sep);
  fprintf(fp,"%4.1f%1s",rm.T0,sep);
  fprintf(fp,"%6.1f\r\n",rm.P0);

  // Line 3
  fprintf(fp,"%1s",beg);
  fprintf(fp,"%07d%1s",rm.nshoots,sep);
  fprintf(fp,"%04d%1s",rm.nhz,sep);
  fprintf(fp,"%07d%1s",rm.nshoots2,sep);
  fprintf(fp,"%04d%1s",rm.nhz2,sep);
  fprintf(fp,"%02d%1s",rm.nch,sep);
  fprintf(fp,"%48s\r\n"," ");
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
  fprintf(stderr,"start: %s\n",rm.start.write2nc().c_str());
  fprintf(stderr,"end: %s\n",rm.end.write2nc().c_str());
  fprintf(stderr,"altitude (m): %d\n",rm.alt);
  fprintf(stderr,"position (lat/lon): %f %f\n",rm.lat,rm.lon);
  fprintf(stderr,"zenith: %d \n",rm.zen);
  fprintf(stderr,"Reference temperature (C): %f \n",rm.T0);
  fprintf(stderr,"Reference pressure (mb): %f \n",rm.P0);
  fprintf(stderr,"Num. of shoots= %d\n", rm.nshoots);
  fprintf(stderr,"repetition rate= %d\n", rm.nhz);
  fprintf(stderr,"Num. of shoots2= %d\n", rm.nshoots2);
  fprintf(stderr,"repetition rate2= %d\n", rm.nhz2);
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

  fprintf(fp,"\r\n");

  // for each channel
  for (int i=0; i<rm.nch; i++) { 
    ierr=fwrite(rm.ch[i].raw, sizeof(bin), rm.ch[i].ndata, fp);
    fprintf(fp,"\r\n");

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

/* Compares two profiles for compatibility. This is usually used
   before adding, averaging or merging two profiles. It halts the
   program on different errors.
 */
void check_profiles (RMDataFile A, RMDataFile B) 
{
  /* ************** RM DATA FILE **********************************   */
  /* ************** CHECKS ****************************************   */

  // check site name
  if (strcmp(A.site, B.site)) {
    fprintf(stderr,"Sites are different!\n");
    fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
    exit(1);
  }
  // check alt, lon, lat, zen
  if (A.alt!=B.alt) {
    fprintf(stderr,"Altitudes are different!\n");
    fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
    exit(1);
  }
  if (A.lon!=B.lon) {
    fprintf(stderr,"Longitudes are different!\n");
    fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
    exit(1);
  }
  if (A.lat!=B.lat) {
    fprintf(stderr,"Latitudes are different!\n");
    fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
    exit(1);
  }
  if (A.zen!=B.zen) {
    fprintf(stderr,"Zeniths are different!\n");
    fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
    exit(1);
  }
  // check repetition rates
  if (A.nhz!=B.nhz || A.nhz2!=B.nhz2 ) {
    fprintf(stderr,"Laser repetition rates are different!\n");
    fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
    exit(1);
  }  
  // check number of channels
  if (A.nch!=B.nch) {
    fprintf(stderr,"Number of channels are different!\n");
    fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
    exit(1);
  }

  // LOOP TROUGH CHANNELS
  for (int i=0; i<A.nch; i++) {

    /* ************** CHANNELS **************************************   */
    /* ************** CHECKS ****************************************   */

    // check channel activation
    if (A.ch[i].active != B.ch[i].active) {
      fprintf(stderr,"Channel #%d 'active' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel photons
    if (A.ch[i].photons != B.ch[i].photons) {
      fprintf(stderr,"Channel #%d 'photons' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel elastic
    if (A.ch[i].elastic != B.ch[i].elastic) {
      fprintf(stderr,"Channel #%d 'elastic' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel ndata
    if (A.ch[i].ndata != B.ch[i].ndata) {
      fprintf(stderr,"Channel #%d 'ndata' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel pmtv
    if (A.ch[i].pmtv != B.ch[i].pmtv) {
      fprintf(stderr,"Channel #%d 'pmtv' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel binw
    if (A.ch[i].binw != B.ch[i].binw) {
      fprintf(stderr,"Channel #%d 'binw' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel wlen
    if (A.ch[i].wlen != B.ch[i].wlen) {
      fprintf(stderr,"Channel #%d 'wlen' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel pol
    if (A.ch[i].pol != B.ch[i].pol) {
      fprintf(stderr,"Channel #%d 'pol' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel bits
    if (A.ch[i].bits != B.ch[i].bits) {
      fprintf(stderr,"Channel #%d 'bits' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel discr
    if (A.ch[i].discr != B.ch[i].discr) {
      fprintf(stderr,"Channel #%d 'discr' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
    // check channel tr
    if (strcmp(A.ch[i].tr,B.ch[i].tr)) {
      fprintf(stderr,"Channel #%d 'tr' is different!\n",i);
      fprintf(stderr,"files: %s vs. %s\n",A.file,B.file);
      exit(1);
    }
  }

}

void profile_add (RMDataFile *acum, RMDataFile toadd) 
{
  float dScale; // conversion between raw and physical data

  /* ************** RM DATA FILE **********************************   */
  /* ************** CHECKS ****************************************   */

  check_profiles(*acum, toadd);

  /* ************** RM DATA FILE **********************************   */
  /* ************** SUMS   ****************************************   */
  //std::cerr << toadd.start.write2hms(':') << '\t' << acum->start.write2hms(':') << endl;
  //std::cerr << toadd.end.write2hms(':') << '\t' << acum->end.write2hms(':') << endl;
  //std::cerr << toadd.end.GetJD() - acum->end.GetJD() << endl;
  // update start/end dates
  if (toadd.start < acum->start) {
    acum->start = RM_Date(toadd.start);
  }
  if (toadd.end > acum->end ) {
    //std::cerr << "entrou\n";
    acum->end = RM_Date(toadd.end);
  }

  // Number of files added
  acum->idum++;
//  if (acum->idum>99) {
//    fprintf(stderr,"Maximum number of files to average is 100!\n");
//    exit(1);    
//  }

  // average T0,P0
  acum->T0=((acum->T0)*(acum->idum)+toadd.T0)/(acum->idum+1);
  acum->P0=((acum->P0)*(acum->idum)+toadd.P0)/(acum->idum+1);

  // acumulate shoots
  acum->nshoots+=toadd.nshoots;
  acum->nshoots2+=toadd.nshoots2;

  
  // LOOP TROUGH CHANNELS
  for (int i=0; i<acum->nch; i++) {

    // add number of shoots
    acum->ch[i].nshoots += toadd.ch[i].nshoots;

    // add raw data
    for (int j=0; j<acum->ch[i].ndata; j++)
      acum->ch[i].raw[j] += toadd.ch[i].raw[j];

    // convert again to physical units
    if (!acum->ch[i].photons)
      dScale = acum->ch[i].nshoots*pow(2,acum->ch[i].bits)/(acum->ch[i].discr*1.e3);
    else 
      dScale = acum->ch[i].nshoots/PCsampling;
    
    for (int j=0; j<acum->ch[i].ndata; j++) 
      acum->ch[i].phy[j] = (float) acum->ch[i].raw[j] / dScale;

  } // end channel loop

} // end subroutine

/*
  Function: read_single_file
  Description: read one lidar file and store all data inside a RMDataFile variable
  Author: hbarbosa
  Date: 17 Aug 2011
 */
int profile_read (const char* fname, RMDataFile *rm, bool debug, bool noraw) 
{
  FILE *fp; // file pointer
  size_t nread; // amount of data read
  float dScale; // conversion between raw and physical data
  char szBuffer[90]; // dummy buffer
  int n;
  
  Init_RMDataFile(rm);
  
  // OPEN DATA FILE
  //15nov11 - we should open explicitly as binary
  fp=fopen(fname,"rb");
  if (debug) {
    fprintf(stderr,"pos after open: %ld\n",ftell(fp));
  }

  // READ THE FIRST 3 LINES
  header_read(fp, rm, debug);
  if (debug) {
    header_debug(*rm);
    fprintf(stderr,"pos after header: %ld\n",ftell(fp));
  }
  
  if (noraw) return 0;

  // ALLOCATE MEMORY FOR HOLDING CHANNELS
  rm->ch=(channel*) malloc(rm->nch*sizeof(channel));
  
  // READ LINES DESCRIBING CHANNELS
  for (int i=0; i<rm->nch; i++) {
    channel_read(fp, &rm->ch[i]);
    if (debug) {
      channel_debug(rm->ch[i]);
      fprintf(stderr,"pos after channel: %ld\n",ftell(fp));
    }
  }

  // after all channels there is an extra empty line
  n=fscanf(fp,"%*[^\n]"); n=fscanf(fp,"%*c");

  // READ ACTUAL DATA (IN BINARY FORMAT)
  for (int i=0; i<rm->nch; i++) {
    if (rm->ch[i].active!=0) {
      rm->ch[i].raw = (bin *) malloc(sizeof(bin)*rm->ch[i].ndata);
      rm->ch[i].phy = (float *) malloc(sizeof(float)*rm->ch[i].ndata);
      
      // read from file and check amount of data read
      if (debug) {
        nread=0;
        fprintf(stderr,"pos before raw: %ld\n",ftell(fp));        
        for (int k=0; k<rm->ch[i].ndata; k++) {
          n=fread(&rm->ch[i].raw[k],sizeof(bin),1,fp);
          nread++;
        }
        fprintf(stderr,"pos after raw: %ld\n",ftell(fp));        
      } else {
        nread=fread(rm->ch[i].raw,sizeof(bin),rm->ch[i].ndata,fp);
      }
      if (debug) {
        //channel_debug_raw(rm->ch[i]);
        fprintf(stderr,"\n -------- channel: : %d \n", i);
        fprintf(stderr,"\n amount of data read: %d \n", (int) nread);
      }
      //      cerr << "aqui\n"<<endl;
      if(nread<(sizeof(bin)*rm->ch[i].ndata)) {
        if(file_error(fp)!=0) {
          fprintf(stderr,"\nblock %d corrupt",i+1);
          fprintf(stderr,"file: %s\n",fname);
          Init_RMDataFile(rm);
          return(1);
        }
      }
      //      cerr << "aqui2\n"<<endl;
      // convert data to physical units
      if (!rm->ch[i].photons)
        dScale = rm->ch[i].nshoots*pow(2,rm->ch[i].bits)/(rm->ch[i].discr*1.e3);
      else 
        dScale = rm->ch[i].nshoots/PCsampling;
      
      for (int j=0; j<rm->ch[i].ndata; j++) 
        rm->ch[i].phy[j] = (float) rm->ch[i].raw[j] / dScale;

      //if (debug) channel_debug_phy(rm->ch[i]);

      // read end of line
      if(fgets(szBuffer,90,fp)==NULL) {
        if(file_error(fp)!=0) {
          fprintf(stderr,"\nmarker %d corrupt\n",i+1);
          fprintf(stderr,"file: %s\n",fname);
          Init_RMDataFile(rm);
          return(2);
        }
      }

    }// is chanel active?
  }// chanel read

  return (0);
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
