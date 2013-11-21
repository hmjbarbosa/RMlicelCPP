/* RMlicelUSP.h -- defines, typedefs, and data structures for reading
   Raymetrics/licel data files @USP.
 */
#ifndef _RMNETCDFUSP_H
#define _RMNETCDFUSP_H

#include "netcdf.h"
#include "RMlicelUSP.h"

#define version "20nov13"

#define NDIMS 4 // t, z, lat, lon
#define NCHANNELS 100 // max number of channels in a file

extern void handle_error(int status, int pos);
extern void profile_write_netcdf(const char* fname, RMDataFile rm, int tropt);
extern void profile_add_netcdf(const char* fname, 
                               RMDataFile First, RMDataFile toadd);

#endif /* _RMNETCDFUSP_H */
