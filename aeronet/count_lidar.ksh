#!/bin/ksh -x

here=`pwd`

base='/home/lidar_data/data'

cd $base

rm -f $here/list_days.txt 2>/dev/null
for arq in `find */*/* -maxdepth 0 -type d` ; do 
    N=`find $arq -type f | wc -l`
    echo "$arq $N" >> $here/list_days.txt
done

rm -f $here/list_mon.txt 2>/dev/null
for arq in `find */* -maxdepth 0 -type d` ; do 
    N=`find $arq -type f | wc -l`
    echo "$arq $N" >> $here/list_mon.txt
done
