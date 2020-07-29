#include "RMnetcdfUSP.h"

// ID for time as dimension or variable
int t_dimid, t_varid;
// ID for Z as dimension or variable
int z_dimid, z_varid;
// ID for lat as dimension or variable
int lat_dimid, lat_varid;
// ID for lon as dimension or variable
int lon_dimid, lon_varid;

// netCDF id of channels
int chnid[NCHANNELS];

// netCDF id of file_char
//int fchar_varid;

/*
  Function: handle_error
  Description: handle netcdf errors
  Author: hbarbosa
  Date: 8 october 2011
 */
void handle_error(int status, int pos) 
{
  if (status==NC_EBADID      ) std::cerr << pos << "NETCDF:: Not a netcdf id!\n";
  if (status==NC_ENFILE      ) std::cerr << pos << "NETCDF:: Too many netcdfs open!\n";
  if (status==NC_EEXIST      ) std::cerr << pos << "NETCDF:: netcdf file exists && NC_NOCLOBBER!\n";
  if (status==NC_EINVAL      ) std::cerr << pos << "NETCDF:: Invalid Argument!\n";
  if (status==NC_EPERM       ) std::cerr << pos << "NETCDF:: Write to read only!\n";
  if (status==NC_ENOTINDEFINE) std::cerr << pos << "NETCDF:: Operation not allowed in data mode!\n";
  if (status==NC_EINDEFINE   ) std::cerr << pos << "NETCDF:: Operation not allowed in define mode!\n";
  if (status==NC_EINVALCOORDS) std::cerr << pos << "NETCDF:: Index exceeds dimension bound!\n";
  if (status==NC_EMAXDIMS    ) std::cerr << pos << "NETCDF:: NC_MAX_DIMS exceeded!\n";
  if (status==NC_ENAMEINUSE  ) std::cerr << pos << "NETCDF:: String match name already in use!\n";
  if (status==NC_ENOTATT     ) std::cerr << pos << "NETCDF:: Attribute not found!\n";
  if (status==NC_EMAXATTS    ) std::cerr << pos << "NETCDF:: NC_MAX_ATTRS exceeded!\n";
  if (status==NC_EBADTYPE    ) std::cerr << pos << "NETCDF:: Not a netcdf data type!\n";
  if (status==NC_EBADDIM     ) std::cerr << pos << "NETCDF:: Invalid dimension id or name!\n";
  if (status==NC_EUNLIMPOS   ) std::cerr << pos << "NETCDF:: NC_UNLIMITED in the wrong index!\n";
  if (status==NC_EMAXVARS    ) std::cerr << pos << "NETCDF:: NC_MAX_VARS exceeded!\n";
  if (status==NC_ENOTVAR     ) std::cerr << pos << "NETCDF:: Variable not found!\n";
  if (status==NC_EGLOBAL     ) std::cerr << pos << "NETCDF:: Action prohibited on NC_GLOBAL varid!\n";
  if (status==NC_ENOTNC      ) std::cerr << pos << "NETCDF:: Not a netcdf file!\n";
  if (status==NC_ESTS        ) std::cerr << pos << "NETCDF:: In Fortran, string too short!\n";
  if (status==NC_EMAXNAME    ) std::cerr << pos << "NETCDF:: NC_MAX_NAME exceeded!\n";
  if (status==NC_EUNLIMIT    ) std::cerr << pos << "NETCDF:: NC_UNLIMITED size already in use!\n";
  if (status==NC_ENORECVARS  ) std::cerr << pos << "NETCDF:: nc_rec op when there are no record vars!\n";
  if (status==NC_ECHAR       ) std::cerr << pos << "NETCDF:: Attempt to convert between text & numbers!\n";
  if (status==NC_EEDGE       ) std::cerr << pos << "NETCDF:: Edge+start exceeds dimension bound!\n";
  if (status==NC_ESTRIDE     ) std::cerr << pos << "NETCDF:: Illegal stride!\n";
  if (status==NC_EBADNAME    ) std::cerr << pos << "NETCDF:: Attribute or variable name contains illegal characters!\n";
  if (status==NC_ERANGE      ) std::cerr << pos << "NETCDF:: Math result not representable!\n";
  if (status==NC_ENOMEM      ) std::cerr << pos << "NETCDF:: Memory allocation (malloc) failure!\n";
  if (status==NC_EVARSIZE    ) std::cerr << pos << "NETCDF:: One or more variable sizes violate format constraints!\n";
  if (status==NC_EDIMSIZE    ) std::cerr << pos << "NETCDF:: Invalid dimension size!\n";
  if (status==NC_ETRUNC      ) std::cerr << pos << "NETCDF:: File likely truncated or possibly corrupted!\n";

  exit(-1);
}

void profile_add_netcdf(const char* fname, RMDataFile First, RMDataFile toadd) 
{
  // return code of netCDF function calls
  int ok;
  
  // netCDF id of file
  int ncid;

  // number of bins in vertical
  size_t zmax;
  // number of times so far
  size_t tmax;
  // difference in minutes from start to current profile
  int tdif;

  // for filling time data
  float tval[1];
  size_t tpos[1];

  // for filling channel data
  size_t chpos[NDIMS];
  size_t chcount[NDIMS];

  // temporary string for writing netCDF attributes
  char longstr[256];

  char verylongstr[36000];

  /* ************** RM DATA FILE **********************************   */
  /* ************** CHECKS ****************************************   */

  check_profiles(First, toadd);

  /* ************** NETCDF  FILE **********************************   */
  /* ************** WRITE  ****************************************   */
  ok=nc_open(fname, NC_WRITE, &ncid);
  if (ok != NC_NOERR) handle_error(ok,1);

  // get size of vertical
  ok=nc_inq_dimlen(ncid, z_dimid, &zmax);
  if (ok != NC_NOERR) handle_error(ok,2);
  //std::cerr << "==============\n";
  //std::cerr << First.file << "\n";
  //std::cerr << toadd.file << "\n";
  //std::cerr << zmax << "\n";
  
  // Fill time info

  // get number of 'times' currently in this file
  ok=nc_inq_dimlen(ncid, t_dimid, &tmax);
  if (ok != NC_NOERR) handle_error(ok,4);
  //std::cerr << tmax << "\n";
  
  // we now save time as seconds after some time
  // therefore, time will jump in steps, typically, of 30s or 60s
  // this means that tdif and tpos are not the same anymore
  
  tdif=toadd.end.SecDiff(First.end);
  //std::cerr << tdif << "\n";
  if (tdif<0) {
    std::cerr << "Files must be in chronological order!\n";
    exit(1);
  }

  // time value for this profile, in seconds since first file
  tval[0]=tdif;
  // save this extra profile in the next time slot
  // (start counting from 0, so no +1 here)
  tpos[0]=tmax;

  //std::cerr << First.end.write2nc() << "\n";
  //std::cerr << First.end.GetJD() << "\n";
  //std::cerr << First.end.GetSecD() << "\n";
  //std::cerr << toadd.end.write2nc() << "\n";
  //std::cerr << toadd.end.GetJD() - First.end.GetJD() << "\n";
  //std::cerr << toadd.end.GetSecD() << "\n";
  
  ok=nc_put_var1_float(ncid, t_varid, tpos, tval);
  if (ok != NC_NOERR) handle_error(ok,3);

  // because time is unlimited we cannot fill the whole array at once
  chpos[0]=tmax; chcount[0]=1;
  chpos[1]=0;    chcount[1]=zmax;
  chpos[2]=0;    chcount[2]=1;
  chpos[3]=0;    chcount[3]=1;
  for (int i=0; i<toadd.nch; i++) {
    if (toadd.ch[i].active==1) {
      ok=nc_put_vara_float(ncid, chnid[i], chpos, chcount, toadd.ch[i].phy);
    }
  }

  // july-2020
  // because we now save time as seconds, doesn't make sense to try to fill
  // "missing" times with NaN

  /* 

  // if there are missing times, fill them
  // no need to test first (0th) and last (tmax-th) because
  // they are obviously correct
  for (size_t i=1; i<tmax-1; i++) {
    nc_get_var1_float(ncid, t_varid, &i, tval);
    if (tval[0]==-999.) {
      tval[0]=i;
      nc_put_var1_float(ncid,t_varid, &i, tval);
    }
  }

  */

  // and we should always update the attributes after adding +1 file
  
  // if last file, update attributes
  //if (tpos[0] == tmax-1 ){
    ok=nc_redef(ncid);
    if (ok != NC_NOERR) handle_error(ok,5);

    sprintf(longstr,"%s",toadd.end.write2nc().c_str());
    ok=nc_put_att_text(ncid, NC_GLOBAL, "end_time",strlen(longstr),longstr);
    if (ok != NC_NOERR) handle_error(ok,6);

    ok=nc_get_att_text(ncid, NC_GLOBAL, "file_char", verylongstr);
    if (ok != NC_NOERR) handle_error(ok,666);
    //std::cerr << verylongstr << "\n";
    
    sprintf(verylongstr,"%s%s;",verylongstr,toadd.file);
    //std::cerr << verylongstr << "\n";
    
    ok=nc_put_att_text(ncid, NC_GLOBAL, "file_char", strlen(verylongstr), verylongstr);

    //int nc_put_att_text(int ncid, int varid, const char name[], nc_type xtype,  size_t  len,  const  char out[])                       
    //int nc_get_att_text(int ncid, int varid, const char name[], char in[])                       
    
    ok=nc_enddef(ncid);
    if (ok != NC_NOERR) handle_error(ok,7);
  //}

  // CLOSE netcdf FILE
  ok=nc_close(ncid);
  if (ok != NC_NOERR) handle_error(ok,8);

}

/*
  Function: profile_write_netcdf
  Description: Writes a RMDataFile as a netcdf file
  Author: hbarbosa
  Date: 8 october 2011
 */
void profile_write_netcdf(const char* fname, RMDataFile rm, int tropt) 
{
  // return code of netCDF function calls
  int ok;
  
  // netCDF id of file
  int ncid;
  // netCDF id of dimensions (T, Z, Y, X)
  int dimid[NDIMS];

  // temporary string for writing netCDF attributes
  char longstr[256];

  // long arrays
  float *fval;
  float tval[1];
  size_t tpos[1], chpos[NDIMS], chcount[NDIMS];

  // max number of bins in all channels
  int zmax;
  // start minute
  //  int minute;
  // a date
  //  date adate;
  RM_Date adate;

  /*
   * CREATE EMPTY NETCDF FILE
   */ 
  ok=nc_create(fname, NC_NOCLOBBER, &ncid);
  if (ok != NC_NOERR) handle_error(ok,9);

  /*
   * DEFINE VARIABLES. Although lat/lon are generally fixed, COARDS
   * convection require them to be defined as variables
   */
  
  ok=nc_def_dim(ncid, "time", NC_UNLIMITED, &t_dimid);
  if (ok != NC_NOERR) handle_error(ok,9);

  // max number of bins in all channels
  zmax=-1;
  for (int i=0; i<rm.nch; i++)
    if (rm.ch[i].ndata > zmax) 
      zmax=rm.ch[i].ndata;
 
  ok=nc_def_dim(ncid, "z"   , zmax, &z_dimid);
  if (ok != NC_NOERR) handle_error(ok,10);

  ok=nc_def_dim(ncid, "lat" , 1   , &lat_dimid);
  if (ok != NC_NOERR) handle_error(ok,11);

  ok=nc_def_dim(ncid, "lon" , 1   , &lon_dimid);
  if (ok != NC_NOERR) handle_error(ok,12);

  dimid[0]=t_dimid;
  dimid[1]=z_dimid;
  dimid[2]=lat_dimid;
  dimid[3]=lon_dimid;

  /*
   * TIME IN SECONDS
   */

  // Note: Grads will not accept a smaller time-step than 1min
    
  ok=nc_def_var(ncid, "time", NC_FLOAT, 1, &t_dimid, &t_varid);
  if (ok != NC_NOERR) handle_error(ok,13);

  ok=nc_put_att_text(ncid, t_varid, "title", 4, "time");
  if (ok != NC_NOERR) handle_error(ok,14);

  ok=nc_put_att_text(ncid, t_varid, "long_name", 16, "profile end time");
  if (ok != NC_NOERR) handle_error(ok,15);

  // Save time with seconds, as there are acquisitions with interval
  // less than 1min. And save the end time, because the filename is
  // associated with THAT time

  //adate=RM_Date(rm.end);
  //adate.RoundMinutes();
  //sprintf(longstr,"minutes since %s",adate.write2nc().c_str());
  sprintf(longstr,"seconds since %s",rm.end.write2nc().c_str());
  ok=nc_put_att_text(ncid, t_varid, "units",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok,16);
  
  tval[0]=-999.;
  ok=nc_put_att_float(ncid, t_varid, "_FillValue", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,17);

  /*
   * BINS ABOVE GROUND
   */
  
  ok=nc_def_var(ncid, "z", NC_FLOAT, 1, &z_dimid, &z_varid);
  if (ok != NC_NOERR) handle_error(ok,18);
  
  ok=nc_put_att_text(ncid, z_varid, "title", 1, "z");
  if (ok != NC_NOERR) handle_error(ok,19);

  ok=nc_put_att_text(ncid, z_varid, "long_name", 1, "z");
  if (ok != NC_NOERR) handle_error(ok,20);

  ok=nc_put_att_text(ncid, z_varid, "units", 5, "level");
  if (ok != NC_NOERR) handle_error(ok,21);

  tval[0]=0.;
  ok=nc_put_att_float(ncid, z_varid, "valid_min", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,27);

  tval[0]=16000.;
  ok=nc_put_att_float(ncid, z_varid, "valid_max", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,27);
  
  tval[0]=-999.;
  ok=nc_put_att_float(ncid, z_varid, "_FillValue", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,22);

  ok=nc_put_att_text(ncid, z_varid, "positive", 2, "up");
  if (ok != NC_NOERR) handle_error(ok,23);

  /*
   * LATITUDE
   */
  
  ok=nc_def_var(ncid, "lat" , NC_FLOAT, 1, &lat_dimid, &lat_varid);
  if (ok != NC_NOERR) handle_error(ok,24);

  ok=nc_put_att_text(ncid, lat_varid, "title", 8, "latitude");
  if (ok != NC_NOERR) handle_error(ok,25);

  ok=nc_put_att_text(ncid, lat_varid, "long_name", 14, "North latitude");
  if (ok != NC_NOERR) handle_error(ok,26);

  ok=nc_put_att_text(ncid, lat_varid, "units", 13, "degrees_north");
  if (ok != NC_NOERR) handle_error(ok,27);

  tval[0]=-90.;
  ok=nc_put_att_float(ncid, lat_varid, "valid_min", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,27);

  tval[0]=90.;
  ok=nc_put_att_float(ncid, lat_varid, "valid_max", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,27);

  tval[0]=-999.;
  ok=nc_put_att_float(ncid, lat_varid, "_FillValue", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,28);

  /*
   * LONGITUDE
   */
  
  ok=nc_def_var(ncid, "lon" , NC_FLOAT, 1, &lon_dimid, &lon_varid);
  if (ok != NC_NOERR) handle_error(ok,29);

  ok=nc_put_att_text(ncid, lon_varid, "title", 9, "longitude");
  if (ok != NC_NOERR) handle_error(ok,30);

  ok=nc_put_att_text(ncid, lon_varid, "long_name", 14, "East longitude");
  if (ok != NC_NOERR) handle_error(ok,31);

  ok=nc_put_att_text(ncid, lon_varid, "units", 12, "degrees_east");
  if (ok != NC_NOERR) handle_error(ok,32);

  tval[0]=-180.;
  ok=nc_put_att_float(ncid, lon_varid, "valid_min", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,27);

  tval[0]=180.;
  ok=nc_put_att_float(ncid, lon_varid, "valid_max", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,27);

  tval[0]=-999.;
  ok=nc_put_att_float(ncid, lon_varid, "_FillValue", NC_FLOAT, 1, tval);
  if (ok != NC_NOERR) handle_error(ok,33);

  /*
   * FILE_CHAR
   */
  //ok=nc_def_var(ncid, "file_char" , NC_STRING, 1, &t_dimid, &fchar_varid); 
  //if (ok != NC_NOERR) handle_error(ok,521);


  /*
   * GENERAL SITE INFORMATION
   */
  
  ok=nc_put_att_text(ncid, NC_GLOBAL, "title",strlen(title),title);
  if (ok != NC_NOERR) handle_error(ok,34);
  
  ok=nc_put_att_text(ncid, NC_GLOBAL, "contact",strlen(contact),contact);
  if (ok != NC_NOERR) handle_error(ok,35);

  sprintf(longstr,"Converted from original format by rm2nc v.%s",version);
  ok=nc_put_att_text(ncid, NC_GLOBAL, "history",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok,36);

  sprintf(longstr,"http://www.unidata.ucar.edu/netcdf/conventions.html + COARDS");
  ok=nc_put_att_text(ncid, NC_GLOBAL, "Conventions",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok,37);

  // add a ; after the file name
  sprintf(longstr,"%s;",rm.file);
  ok=nc_put_att_text(ncid, NC_GLOBAL, "file_char", strlen(longstr), longstr);
  if (ok != NC_NOERR) handle_error(ok,38);

  ok=nc_put_att_text(ncid, NC_GLOBAL, "site_char", strlen(rm.site), rm.site);
  if (ok != NC_NOERR) handle_error(ok,39);

  sprintf(longstr,"%s",rm.start.write2nc().c_str());
  ok=nc_put_att_text(ncid, NC_GLOBAL, "start_time",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok,40);

  sprintf(longstr,"%s",rm.end.write2nc().c_str());
  ok=nc_put_att_text(ncid, NC_GLOBAL, "end_time",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok,41);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "alt_meters", NC_INT, 1, &rm.alt);
  if (ok != NC_NOERR) handle_error(ok,42);

  ok=nc_put_att_float(ncid, NC_GLOBAL, "lon_deg", NC_FLOAT, 1, &rm.lon);
  if (ok != NC_NOERR) handle_error(ok,43);

  ok=nc_put_att_float(ncid, NC_GLOBAL, "lat_deg", NC_FLOAT, 1, &rm.lat);
  if (ok != NC_NOERR) handle_error(ok,44);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "zen_deg", NC_INT, 1, &rm.zen);
  if (ok != NC_NOERR) handle_error(ok,45);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "idum", NC_INT, 1, &rm.idum);
  if (ok != NC_NOERR) handle_error(ok,46);

  ok=nc_put_att_float(ncid, NC_GLOBAL, "T0_degC", NC_FLOAT, 1, &rm.T0);
  if (ok != NC_NOERR) handle_error(ok,47);

  ok=nc_put_att_float(ncid, NC_GLOBAL, "P0_mbar", NC_FLOAT, 1, &rm.P0);
  if (ok != NC_NOERR) handle_error(ok,48);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "nshoots_n", NC_INT, 1, &rm.nshoots);
  if (ok != NC_NOERR) handle_error(ok,49);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "nhz_hz", NC_INT, 1, &rm.nhz);
  if (ok != NC_NOERR) handle_error(ok,50);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "nch_n", NC_INT, 1, &rm.nch);
  if (ok != NC_NOERR) handle_error(ok,51);
  
  /*
   * CHANNEL INFORMATION
   */
  //std:: cerr << "aqui1" << std::endl;
  
  for (int i=0; i<rm.nch; i++) {
    if (rm.ch[i].active==1) {

      //std:: cerr << rm.ch[i].tr << std::endl;
      // NAMES
      if (tropt==1)
        sprintf(longstr,"%s",rm.ch[i].tr);
      else
        if (rm.ch[i].photons==1)
          sprintf(longstr,"ch%dpc",rm.ch[i].wlen);
        else
          sprintf(longstr,"ch%dan",rm.ch[i].wlen);

      //std:: cerr << longstr << std::endl;
      fflush(stderr);

      ok=nc_def_var(ncid, longstr , NC_FLOAT, NDIMS, dimid, &chnid[i]);
      if (ok != NC_NOERR) handle_error(ok,52);

      sprintf(longstr,"channel%d lamb=%d phot=%d elastic=%d",
              i,rm.ch[i].wlen,rm.ch[i].photons,rm.ch[i].elastic);
      ok=nc_put_att_text(ncid, chnid[i], "title", strlen(longstr), longstr);
      if (ok != NC_NOERR) handle_error(ok,53);
      ok=nc_put_att_text(ncid, chnid[i], "long_name", strlen(longstr), longstr);
      if (ok != NC_NOERR) handle_error(ok,54);

      // PHYSICAL UNITS OF FLOAT DATA
      if (rm.ch[i].photons)
        ok=nc_put_att_text(ncid, chnid[i], "units", 3, "MHz");
      else
        ok=nc_put_att_text(ncid, chnid[i], "units", 2, "mV");
      if (ok != NC_NOERR) handle_error(ok,55);

      tval[0]=-999.;
      ok=nc_put_att_float(ncid, chnid[i], "_FillValue", NC_FLOAT, 1, tval);
      if (ok != NC_NOERR) handle_error(ok,56);

      ok=nc_put_att_text(ncid, chnid[i], "C_format", 4, "%.4f");
      if (ok != NC_NOERR) handle_error(ok,57);

      ok=nc_put_att_int(ncid, chnid[i], "active", NC_INT, 1, &rm.ch[i].active);
      if (ok != NC_NOERR) handle_error(ok,58);

      ok=nc_put_att_int(ncid, chnid[i], "photons", NC_INT, 1, &rm.ch[i].photons);
      if (ok != NC_NOERR) handle_error(ok,59);

      ok=nc_put_att_int(ncid, chnid[i], "elastic", NC_INT, 1, &rm.ch[i].elastic);
      if (ok != NC_NOERR) handle_error(ok,60);

      ok=nc_put_att_int(ncid, chnid[i], "ndata", NC_INT, 1, &rm.ch[i].ndata);
      if (ok != NC_NOERR) handle_error(ok,61);

      ok=nc_put_att_int(ncid, chnid[i], "pmtv", NC_INT, 1, &rm.ch[i].pmtv);
      if (ok != NC_NOERR) handle_error(ok,62);

      ok=nc_put_att_float(ncid, chnid[i], "binw", NC_FLOAT, 1, &rm.ch[i].binw);
      if (ok != NC_NOERR) handle_error(ok,63);

      ok=nc_put_att_int(ncid, chnid[i], "wlen", NC_INT, 1, &rm.ch[i].wlen);
      if (ok != NC_NOERR) handle_error(ok,64);

      ok=nc_put_att_text(ncid, chnid[i], "pol", 1, &rm.ch[i].pol);
      if (ok != NC_NOERR) handle_error(ok,65);

      ok=nc_put_att_int(ncid, chnid[i], "bits", NC_INT, 1, &rm.ch[i].bits);
      if (ok != NC_NOERR) handle_error(ok,66);

      ok=nc_put_att_int(ncid, chnid[i], "nshoots", NC_INT, 1, &rm.ch[i].nshoots);
      if (ok != NC_NOERR) handle_error(ok,67);

      ok=nc_put_att_float(ncid, chnid[i], "discr", NC_FLOAT, 1, &rm.ch[i].discr);
      if (ok != NC_NOERR) handle_error(ok,68);

      ok=nc_put_att_text(ncid, chnid[i], "tr", 3, rm.ch[i].tr);
      if (ok != NC_NOERR) handle_error(ok,69);
    }
  }
  
  // END DEFINITIONS
  ok=nc_enddef(ncid);
  if (ok != NC_NOERR) handle_error(ok,70);
  
  // Fill arrays for dimensions
  
  //lon
  ok=nc_put_var_float(ncid, lon_varid, &rm.lon);
  if (ok != NC_NOERR) handle_error(ok,71);

  //lat
  ok=nc_put_var_float(ncid, lat_varid, &rm.lat);
  if (ok != NC_NOERR) handle_error(ok,72);

  //z-lev
  fval=(float*) malloc(zmax*sizeof(float));
  for (int i=0; i<zmax; i++) fval[i]=float(i+1);
  ok=nc_put_var_float(ncid, z_varid, fval);
  free(fval);
  if (ok != NC_NOERR) handle_error(ok,72);

  //time
  tval[0]=0; tpos[0]=0;
  ok=nc_put_var1_float(ncid, t_varid, tpos, tval);
  if (ok != NC_NOERR) handle_error(ok,73);
  
  // Fill arrays for data
  // because time is unlimited we cannot fill the whole array at once
  chpos[0]=0; chcount[0]=1;     // time
  chpos[1]=0; chcount[1]=zmax;  // z
  chpos[2]=0; chcount[2]=1;     // lat
  chpos[3]=0; chcount[3]=1;     // lon
  for (int i=0; i<rm.nch; i++) {
    if (rm.ch[i].active==1) {
      ok=nc_put_vara_float(ncid, chnid[i], chpos, chcount, rm.ch[i].phy);
    }
  }
  
  // CLOSE netcdf FILE
  ok=nc_close(ncid);
  if (ok != NC_NOERR) handle_error(ok,74);

}
