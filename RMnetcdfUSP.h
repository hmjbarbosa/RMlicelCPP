/* RMlicelUSP.h -- defines, typedefs, and data structures for reading
   Raymetrics/licel data files @USP.
 */
#ifndef _RMNETCDFUSP_H
#define _RMNETCDFUSP_H

#include "netcdf.h"
#include "RMlicelUSP.h"

#define version "8oct11"

extern void handle_error(int status);
extern void profile_write_netcdf(const char* fname, RMDataFile rm);

#endif /* _RMNETCDFUSP_H */
