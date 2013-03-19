#!/bin/ksh

station="82332"

integer yy=2011
integer mm=1

while (( yy*100+mm <= 201302 )) ; do

    fin=`printf "%s_%04d_%02d.html" $station $yy $mm`

    echo "======================================================================="
    if [[ -e $fin ]]; then
	echo "processando: $fin"
	awk -f processa_mes.awk $fin
    else
	echo "nao encontrei: $fin"
    fi

    mm=mm+1;
    if (( mm > 12 )); then
	mm=1;
	yy=yy+1;
    fi
done

#
