#!/bin/ksh

i=7
while (( $i < 150 )) ; do
    r=`convert color.png[1x1+1+$i] -format "%[fx:int(255*r)]" info:`
    g=`convert color.png[1x1+1+$i] -format "%[fx:int(255*g)]" info:`
    b=`convert color.png[1x1+1+$i] -format "%[fx:int(255*b)]" info:`
    j=$((101+i-7))
    printf "[1x1+1+%03d] R.%d=%03d; G.%d=%03d; B.%d=%03d;\n" $i $j $r $j $g $j $b
    i=$((i+1))
done
#fim
