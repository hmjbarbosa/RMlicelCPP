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

/*
  Function: handle_error
  Description: handle netcdf errors
  Author: hbarbosa
  Date: 8 october 2011
 */
void handle_error(int status) 
{
  if (status==NC_EBADID      ) std::cerr << "Not a netcdf id!\n";
  if (status==NC_ENFILE      ) std::cerr << "Too many netcdfs open!\n";
  if (status==NC_EEXIST      ) std::cerr << "netcdf file exists && NC_NOCLOBBER!\n";
  if (status==NC_EINVAL      ) std::cerr << "Invalid Argument!\n";
  if (status==NC_EPERM       ) std::cerr << "Write to read only!\n";
  if (status==NC_ENOTINDEFINE) std::cerr << "Operation not allowed in data mode!\n";
  if (status==NC_EINDEFINE   ) std::cerr << "Operation not allowed in define mode!\n";
  if (status==NC_EINVALCOORDS) std::cerr << "Index exceeds dimension bound!\n";
  if (status==NC_EMAXDIMS    ) std::cerr << "NC_MAX_DIMS exceeded!\n";
  if (status==NC_ENAMEINUSE  ) std::cerr << "String match to name in use!\n";
  if (status==NC_ENOTATT     ) std::cerr << "Attribute not found!\n";
  if (status==NC_EMAXATTS    ) std::cerr << "NC_MAX_ATTRS exceeded!\n";
  if (status==NC_EBADTYPE    ) std::cerr << "Not a netcdf data type!\n";
  if (status==NC_EBADDIM     ) std::cerr << "Invalid dimension id or name!\n";
  if (status==NC_EUNLIMPOS   ) std::cerr << "NC_UNLIMITED in the wrong index!\n";
  if (status==NC_EMAXVARS    ) std::cerr << "NC_MAX_VARS exceeded!\n";
  if (status==NC_ENOTVAR     ) std::cerr << "Variable not found!\n";
  if (status==NC_EGLOBAL     ) std::cerr << "Action prohibited on NC_GLOBAL varid!\n";
  if (status==NC_ENOTNC      ) std::cerr << "Not a netcdf file!\n";
  if (status==NC_ESTS        ) std::cerr << "In Fortran, string too short!\n";
  if (status==NC_EMAXNAME    ) std::cerr << "NC_MAX_NAME exceeded!\n";
  if (status==NC_EUNLIMIT    ) std::cerr << "NC_UNLIMITED size already in use!\n";
  if (status==NC_ENORECVARS  ) std::cerr << "nc_rec op when there are no record vars!\n";
  if (status==NC_ECHAR       ) std::cerr << "Attempt to convert between text & numbers!\n";
  if (status==NC_EEDGE       ) std::cerr << "Edge+start exceeds dimension bound!\n";
  if (status==NC_ESTRIDE     ) std::cerr << "Illegal stride!\n";
  if (status==NC_EBADNAME    ) std::cerr << "Attribute or variable name contains illegal characters!\n";
  if (status==NC_ERANGE      ) std::cerr << "Math result not representable!\n";
  if (status==NC_ENOMEM      ) std::cerr << "Memory allocation (malloc) failure!\n";
  if (status==NC_EVARSIZE    ) std::cerr << "One or more variable sizes violate format constraints!\n";
  if (status==NC_EDIMSIZE    ) std::cerr << "Invalid dimension size!\n";
  if (status==NC_ETRUNC      ) std::cerr << "File likely truncated or possibly corrupted!\n";

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
  size_t tdif;

  // for filling time data
  float tval[1];
  size_t tpos[1];
  size_t tcount[1];

  // for filling channel data
  size_t chpos[NDIMS];
  size_t chcount[NDIMS];

  /* ************** RM DATA FILE **********************************   */
  /* ************** CHECKS ****************************************   */

  check_profiles(First, toadd);

  /* ************** NETCDF  FILE **********************************   */
  /* ************** WRITE  ****************************************   */
  ok=nc_open(fname, NC_WRITE, &ncid);
  if (ok != NC_NOERR) handle_error(ok);

  // get number of 'times' current in this file
  ok=nc_inq_dimlen(ncid, t_dimid, &tmax);
  if (ok != NC_NOERR) handle_error(ok);

  // get size of vertical
  ok=nc_inq_dimlen(ncid, z_dimid, &zmax);
  if (ok != NC_NOERR) handle_error(ok);

  // Fill time info
  tdif=int(SecDiff(First.end, toadd.end)/60.+0.5);

  //time
  tval[0]=tdif; tpos[0]=tdif;
  ok=nc_put_var1_float(ncid, t_varid, tpos, tval);
  if (ok != NC_NOERR) handle_error(ok);

  // because time is unlimited we cannot fill the whole array at once
  chpos[0]=tdif; chcount[0]=1;
  chpos[1]=0; chcount[1]=zmax;
  chpos[2]=0; chcount[2]=1;
  chpos[3]=0; chcount[3]=1;
  for (int i=0; i<toadd.nch; i++) {
    if (toadd.ch[i].active==1) {
      ok=nc_put_vara_float(ncid, chnid[i], chpos, chcount, toadd.ch[i].phy);
    }
  }

  // CLOSE netcdf FILE
  ok=nc_close(ncid);
  if (ok != NC_NOERR) handle_error(ok);

}

/*
  Function: profile_write_netcdf
  Description: Writes a RMDataFile as a netcdf file
  Author: hbarbosa
  Date: 8 october 2011
 */
void profile_write_netcdf(const char* fname, RMDataFile rm) 
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
  int minute;

  /*
   * CREATE EMPTY NETCDF FILE
   */ 
  ok=nc_create(fname, NC_NOCLOBBER, &ncid);
  if (ok != NC_NOERR) handle_error(ok);

  /*
   * DEFINE VARIABLES. Although lat/lon are generally fixed, COARDS
   * convection require them to be defined as variables
   */
  ok=nc_def_dim(ncid, "time", NC_UNLIMITED, &t_dimid);
  if (ok != NC_NOERR) handle_error(ok);

  // max number of bins in all channels
  zmax=-1;
  for (int i=0; i<rm.nch; i++)
    if (rm.ch[i].ndata > zmax) 
      zmax=rm.ch[i].ndata;
 
  ok=nc_def_dim(ncid, "z"   , zmax, &z_dimid);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_def_dim(ncid, "lat" , 1   , &lat_dimid);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_def_dim(ncid, "lon" , 1   , &lon_dimid);
  if (ok != NC_NOERR) handle_error(ok);

  dimid[0]=t_dimid;
  dimid[1]=z_dimid;
  dimid[2]=lat_dimid;
  dimid[3]=lon_dimid;

  /*
   * TIME IN MINUTES (Grads will not accept a smaller time-step than 1min)
   */
  ok=nc_def_var(ncid, "time", NC_FLOAT, 1, &t_dimid, &t_varid);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, t_varid, "title", 4, "time");
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, t_varid, "long_name", 4, "time");
  if (ok != NC_NOERR) handle_error(ok);

  // now we start at full minutes
  // now we save the end time, because the filename is associated with THAT time
  if (rm.end.ss<30)
    minute = rm.end.mn;
  else
    minute = rm.end.mn+1;

  sprintf(longstr,"minutes since %04d-%02d-%02d %02d:%02d:00 %+02d:00",
          rm.end.YY, rm.end.MM, rm.end.DD, rm.end.hh, minute, UTC);
  ok=nc_put_att_text(ncid, t_varid, "units",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok);

  /*
   * BINS ABOVE GROUND
   */
  ok=nc_def_var(ncid, "z", NC_FLOAT, 1, &z_dimid, &z_varid);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, z_varid, "title", 1, "z");
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, z_varid, "long_name", 1, "z");
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, z_varid, "units", 5, "level");
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, z_varid, "positive", 2, "up");
  if (ok != NC_NOERR) handle_error(ok);

  /*
   * LATITUDE
   */
  ok=nc_def_var(ncid, "lat" , NC_FLOAT, 1, &lat_dimid, &lat_varid);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, lat_varid, "title", 9, "latitude");
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, lat_varid, "long_name", 9, "latitude");
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, lat_varid, "units", 13, "degrees_north");
  if (ok != NC_NOERR) handle_error(ok);

  /*
   * LONGITUDE
   */
  ok=nc_def_var(ncid, "lon" , NC_FLOAT, 1, &lon_dimid, &lon_varid);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, lon_varid, "title", 9, "longitude");
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, lon_varid, "long_name", 9, "longitude");
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, lon_varid, "units", 12, "degrees_east");
  if (ok != NC_NOERR) handle_error(ok);

  /*
   * GENERAL SITE INFORMATION
   */
  sprintf(longstr,"LIDAR data from AEROCLIMA project");
  ok=nc_put_att_text(ncid, NC_GLOBAL, "title",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok);

  sprintf(longstr,"Dr. Henrique M. J. Barbosa (hbarbosa@if.usp.br)");
  ok=nc_put_att_text(ncid, NC_GLOBAL, "contact",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok);

  sprintf(longstr,"Converted from original raymetrics format by rm2nc v.%s",version);
  ok=nc_put_att_text(ncid, NC_GLOBAL, "history",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok);

  sprintf(longstr,"http://www.unidata.ucar.edu/netcdf/conventions.html + COARDS");
  ok=nc_put_att_text(ncid, NC_GLOBAL, "Conventions",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok);
  
  ok=nc_put_att_text(ncid, NC_GLOBAL, "file_char", strlen(rm.file), rm.file);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_text(ncid, NC_GLOBAL, "site_char", strlen(rm.site), rm.site);
  if (ok != NC_NOERR) handle_error(ok);

  sprintf(longstr,"%04d-%02d-%02d %02d:%02d:%02d -4:00",
          rm.start.YY, rm.start.MM, rm.start.DD, rm.start.hh, rm.start.mn, rm.start.ss);
  ok=nc_put_att_text(ncid, NC_GLOBAL, "start_time",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok);

  sprintf(longstr,"%04d-%02d-%02d %02d:%02d:%02d -4:00",
          rm.end.YY, rm.end.MM, rm.end.DD, rm.end.hh, rm.end.mn, rm.end.ss);
  ok=nc_put_att_text(ncid, NC_GLOBAL, "end_time",strlen(longstr),longstr);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "alt_meters", NC_INT, 1, &rm.alt);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_float(ncid, NC_GLOBAL, "lon_deg", NC_INT, 1, &rm.lon);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_float(ncid, NC_GLOBAL, "lat_deg", NC_INT, 1, &rm.lat);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "zen_deg", NC_INT, 1, &rm.zen);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "idum", NC_INT, 1, &rm.idum);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_float(ncid, NC_GLOBAL, "T0_degC", NC_INT, 1, &rm.T0);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_float(ncid, NC_GLOBAL, "P0_mbar", NC_INT, 1, &rm.P0);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "nshoots_n", NC_INT, 1, &rm.nshoots);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "nhz_mhz", NC_INT, 1, &rm.nhz);
  if (ok != NC_NOERR) handle_error(ok);

  ok=nc_put_att_int(ncid, NC_GLOBAL, "nch_n", NC_INT, 1, &rm.nch);
  if (ok != NC_NOERR) handle_error(ok);

  /*
   * CHANNEL INFORMATION
   */
  for (int i=0; i<rm.nch; i++) {
    if (rm.ch[i].active==1) {

      // NAMES
      if (rm.ch[i].photons==1)
        sprintf(longstr,"ch%dpc",rm.ch[i].wlen);
      else
        sprintf(longstr,"ch%dan",rm.ch[i].wlen);
      ok=nc_def_var(ncid, longstr , NC_FLOAT, NDIMS, dimid, &chnid[i]);
      if (ok != NC_NOERR) handle_error(ok);

      sprintf(longstr,"channel%d lamb=%d phot=%d elastic=%d",
              i,rm.ch[i].wlen,rm.ch[i].photons,rm.ch[i].elastic);
      ok=nc_put_att_text(ncid, chnid[i], "title", strlen(longstr), longstr);
      if (ok != NC_NOERR) handle_error(ok);
      ok=nc_put_att_text(ncid, chnid[i], "long_name", strlen(longstr), longstr);
      if (ok != NC_NOERR) handle_error(ok);

      // PHYSICAL UNITS OF FLOAT DATA
      if (rm.ch[i].photons)
        ok=nc_put_att_text(ncid, chnid[i], "units", 3, "MHz");
      else
        ok=nc_put_att_text(ncid, chnid[i], "units", 2, "mV");
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_text(ncid, chnid[i], "C_format", 4, "%.4f");
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_int(ncid, chnid[i], "active", NC_INT, 1, &rm.ch[i].active);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_int(ncid, chnid[i], "photons", NC_INT, 1, &rm.ch[i].photons);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_int(ncid, chnid[i], "elastic", NC_INT, 1, &rm.ch[i].elastic);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_int(ncid, chnid[i], "ndata", NC_INT, 1, &rm.ch[i].ndata);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_int(ncid, chnid[i], "pmtv", NC_INT, 1, &rm.ch[i].pmtv);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_float(ncid, chnid[i], "binw", NC_FLOAT, 1, &rm.ch[i].binw);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_int(ncid, chnid[i], "wlen", NC_INT, 1, &rm.ch[i].wlen);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_text(ncid, chnid[i], "pol", 1, &rm.ch[i].pol);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_int(ncid, chnid[i], "bits", NC_INT, 1, &rm.ch[i].bits);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_int(ncid, chnid[i], "nshoots", NC_INT, 1, &rm.ch[i].nshoots);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_float(ncid, chnid[i], "discr", NC_FLOAT, 1, &rm.ch[i].discr);
      if (ok != NC_NOERR) handle_error(ok);

      ok=nc_put_att_text(ncid, chnid[i], "tr", 3, rm.ch[i].tr);
      if (ok != NC_NOERR) handle_error(ok);
    }
  }

  // END DEFINITIONS
  ok=nc_enddef(ncid);
  if (ok != NC_NOERR) handle_error(ok);

  // Fill arrays for dimensions

  //lon
  ok=nc_put_var_float(ncid, lon_varid, &rm.lon);
  if (ok != NC_NOERR) handle_error(ok);

  //lat
  ok=nc_put_var_float(ncid, lat_varid, &rm.lat);
  if (ok != NC_NOERR) handle_error(ok);

  //z-lev
  fval=(float*) malloc(zmax*sizeof(float));
  for (int i=0; i<zmax; i++) fval[i]=float(i+1);
  ok=nc_put_var_float(ncid, z_varid, fval);
  free(fval);
  if (ok != NC_NOERR) handle_error(ok);

  //time
  tval[0]=0; tpos[0]=0;
  ok=nc_put_var1_float(ncid, t_varid, tpos, tval);
  if (ok != NC_NOERR) handle_error(ok);
    
  // Fill arrays for data
  // because time is unlimited we cannot fill the whole array at once
  chpos[0]=0; chcount[0]=1;
  chpos[1]=0; chcount[1]=zmax;
  chpos[2]=0; chcount[2]=1;
  chpos[3]=0; chcount[3]=1;
  for (int i=0; i<rm.nch; i++) {
    if (rm.ch[i].active==1) {
      ok=nc_put_vara_float(ncid, chnid[i], chpos, chcount, rm.ch[i].phy);
    }
  }

  // CLOSE netcdf FILE
  ok=nc_close(ncid);
  if (ok != NC_NOERR) handle_error(ok);

}
