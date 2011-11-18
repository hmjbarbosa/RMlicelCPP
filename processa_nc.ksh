#!/usr/bin/ksh 
#
# Search for directories of RM files, which is organized as
# year/month/day/rm_files, and convert each file there into
# netCDF. It creates a parallel structure to hold the netCDF version
# of each file.
#
# To gain sometime, only files not already converted are processed. If
# you want to overwrite the files, then change the flag 'erasefirst'.
# User MUST set LIDAR directory, i.e., where to find the lidar files,
# and HOME dir, i.e., where to find RMlicelUSP files.
#
HOME=/home/hbarbosa/Programs/RMlicelUSP

LIDAR=/media/work/EMBRAPA/lidar
#LIDAR=/lfa-data/lidar
erasefirst='no'

DATA=$LIDAR/data
OUT=$LIDAR/level1

cd $DATA
echo "Searching for RM directories like YY/MM/DD/RM..."
for daypath in `find 11/7/21 -type d` ; do
    echo -n "   day: $daypath "
    mkdir -p $OUT/$daypath

    yy=`echo "${daypath}" | awk -F/ '{print $1}'`;yy=`printf "%02d" $yy`
    mm=`echo "${daypath}" | awk -F/ '{print $2}'`;mm=`printf "%02d" $mm`
    dd=`echo "${daypath}" | awk -F/ '{print $3}'`;dd=`printf "%02d" $dd`
    base=`echo "RM_20${yy}_${mm}_${dd}" `

    cd $DATA/$daypath
    rm -f RM*.nc
    for arq in `/bin/ls RM*.???` ; do 

        hh=`echo $arq | awk '{print substr($1,8,2)}'`
        mn=`echo $arq | awk '{print substr($1,11,2)}'`

        name="${base}_${hh}h${mn}.nc"

        if [[ $erasefirst == "yes" ]] ; then
            rm -f $OUT/$daypath/${name}
        fi

        if [ ! -e $OUT/$daypath/${name} ] ; then
            echo -n "."
            ${HOME}/rm2nc $arq
            mv ${name} $OUT/$daypath/
        fi
    done
    echo
done

#fim
