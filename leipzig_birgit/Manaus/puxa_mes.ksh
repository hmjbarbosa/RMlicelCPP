#!/bin/ksh

station="82332"

# Array of month lengths for use by conversion functions
# (Feb 28 is default value only - gets reset to 29 when necessary)
set -A monthlengths dummy 31 28 31 30 31 30 31 31 30 31 30 31

integer yy=2011
integer mm=1

while (( yy*100+mm <= 201302 )) ; do

    if (( yy % 4 == 0 && mm == 2 )) ; then
	mlen=29;
    else
	mlen=${monthlengths[mm]};
    fi

    period=`printf "YEAR=%04d&MONTH=%02d&FROM=0100&TO=%02d12" $yy $mm $mlen`
    fout=`printf "%s_%04d_%02d.html" $station $yy $mm`

    if [[ ! -e $fout ]]; then

	wget http://weather.uwyo.edu/cgi-bin/"sounding?region=samer&TYPE=TEXT%3ALIST&${period}&STNM=${station}" -O $fout

    fi

    mm=mm+1;
    if (( mm > 12 )); then
	mm=1;
	yy=yy+1;
    fi
done

#
