#!/usr/bin/ksh 
#
# Search for directories of netCDF files, which is organized as
# year/month/day/rm_files, creates a CTL to open all days at once with
# grads, and create a png-image for the ch355 analog. It saves the
# result to $HOME/gifs
#
# To gain sometime, only days not already processed are processed. If
# you want to overwrite the images, then change the flag 'erasefirst'.
# User MUST set LIDAR directory, i.e., where to find the lidar files,
# and HOME dir, i.e., where to find RMlicelUSP files.
#
HOME=/home/hbarbosa/Programs/RMlicelUSP

LIDAR=/media/work/EMBRAPA/lidar
#LIDAR=/lfa-server/lidar

DATA=$LIDAR/level1
OUT=$LIDAR/gifs
mkdir -p $OUT

cd $DATA
echo "Searching for netCDF directories like YY/MM/DD/RM*.nc"
for daypath in `find 10/10/* -type d` ; do
    echo "   day: $daypath "

    yy=`echo "${daypath}" | awk -F/ '{print $1}'`
    mm=`echo "${daypath}" | awk -F/ '{print $2}'`
    dd=`echo "${daypath}" | awk -F/ '{print $3}'`
    base=`echo "RM_20${yy}_${mm}_${dd}" `

    if [[ $mm == "01" ]] ; then mon="jan" ; fi
    if [[ $mm == "02" ]] ; then mon="feb" ; fi
    if [[ $mm == "03" ]] ; then mon="mar" ; fi
    if [[ $mm == "04" ]] ; then mon="apr" ; fi
    if [[ $mm == "05" ]] ; then mon="may" ; fi
    if [[ $mm == "06" ]] ; then mon="jun" ; fi
    if [[ $mm == "07" ]] ; then mon="jul" ; fi
    if [[ $mm == "08" ]] ; then mon="aug" ; fi
    if [[ $mm == "09" ]] ; then mon="sep" ; fi
    if [[ $mm == "10" ]] ; then mon="oct" ; fi
    if [[ $mm == "11" ]] ; then mon="nov" ; fi
    if [[ $mm == "12" ]] ; then mon="dec" ; fi

    # go into netCDF directory for current day
    cd $DATA/$daypath

    # find first and last files
    first=`/bin/ls RM*.nc | head -n 1`
    last=`/bin/ls RM*.nc | tail -n 1`

    # and get first and last hour:minute data for current day
    itime=`echo $first | awk '{print substr($1,15,5)}' | sed 's/h/:/'`
    ftime=`echo $last  | awk '{print substr($1,15,5)}' | sed 's/h/:/'`
    ijd=`date -d "$itime" +%s`
    fjd=`date -d "$ftime" +%s`

    # difference in minutes will give the number of timesteps in CTL
    minute=`echo "scale=2; ($fjd-$ijd)/60" | bc `
    minute=`printf "%.0f\n" $minute`

    # create CTL
    cat <<EOF>${base}.ctl
dset ^RM_%y4_%m2_%d2_%h2h%n2.nc
dtype netcdf
options template
tdef time $minute linear ${itime}z${dd}${mon}${yy} 1mn
EOF

    # Creates the image
    cd $HOME
    grads -blxc "run rmday2gif ${DATA}/${daypath}/${base}.ctl"
    mv ${DATA}/${daypath}/${base}.png ${OUT}/

done

#fim
