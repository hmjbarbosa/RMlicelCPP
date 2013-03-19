BEGIN {
    fout="";
    ok=0;
}

/<H2>/ {
    n=index($0,"</H2>");
    station=substr($0,5,5);
    yy=substr($0,n-4,4);
    mes=substr($0,n-8,3);
    dd=substr($0,n-11,2);
    hh=substr($0,n-15,2);
    if (mes=="Jan") mm="01";
    if (mes=="Feb") mm="02";
    if (mes=="Mar") mm="03";
    if (mes=="Apr") mm="04";
    if (mes=="May") mm="05";
    if (mes=="Jun") mm="06";
    if (mes=="Jul") mm="07";
    if (mes=="Aug") mm="08";
    if (mes=="Sep") mm="09";
    if (mes=="Oct") mm="10";
    if (mes=="Nov") mm="11";
    if (mes=="Dec") mm="12";
    fout=station"_"yy"_"mm"_"dd"_"hh"Z.dat";
    print substr($0,5,n-5) > fout;
    print " awk > "fout;
}

/<PRE>/ {
    if (fout!="" && substr($0,1,5)=="<PRE>") ok=1;
}

/<\/PRE>/ {
    if (ok==1) {
	if (substr($0,1,10)=="</PRE><H3>") {
	    print substr($0,11,length($0)-20) >> fout;
	    getline;
	} else {
	    ok=0;
	}
    }
}

{
    if (ok==1) print $0 >> fout;
}