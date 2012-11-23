CC=g++
CHECK=-fbounds-check -fcheck-new -Wextra -ftrapv -fstack-check 
CFLAGS=-c -Wall -O0  -g $(CHECK) 
LFLAGS=-Wall -O0  -g $(CHECK) 

NETCDF=-L/usr/lib -lnetcdf 
# -pthread -static testing.cpp -lnetcdf -lhdf5_hl -lhdf5 -lz  -lm -lcurl -lidn -llber -lldap -lrt -lgssapi_krb5 -lssl -lcrypto -lz -static-libstdc++ -static-libgcc

PROGS=\
	rm2nclist \
	rm2bin \
	rm2csv \
	rm2dat \
	rm2nc \
	rm2name

all	:	$(PROGS)

rm2name	:	rm2name.cpp TimeDate.o RMlicelUSP.o
	$(CC) $(LFLAGS) -o rm2name rm2name.cpp TimeDate.o RMlicelUSP.o

rm2bin	:	rm2bin.cpp TimeDate.o RMlicelUSP.o
	$(CC) $(LFLAGS) -o rm2bin rm2bin.cpp TimeDate.o RMlicelUSP.o

rm2csv	:	rm2csv.cpp TimeDate.o RMlicelUSP.o
	$(CC) $(LFLAGS) -o rm2csv rm2csv.cpp  TimeDate.o RMlicelUSP.o

rm2dat	:	rm2dat.cpp TimeDate.o RMlicelUSP.o
	$(CC) $(LFLAGS) -o rm2dat rm2dat.cpp  TimeDate.o RMlicelUSP.o

rm2nclist	:	rm2nclist.cpp TimeDate.o RMlicelUSP.o RMnetcdfUSP.o
	$(CC) $(LFLAGS) -o rm2nclist rm2nclist.cpp TimeDate.o RMlicelUSP.o RMnetcdfUSP.o $(NETCDF) 

rm2nc	:	rm2nc.cpp TimeDate.o RMlicelUSP.o RMnetcdfUSP.o
	$(CC) $(LFLAGS) -o rm2nc rm2nc.cpp TimeDate.o RMlicelUSP.o RMnetcdfUSP.o $(NETCDF) 

TimeDate.o	:	TimeDate.cpp
	$(CC) $(CFLAGS) TimeDate.cpp

RMlicelUSP.o	:	RMlicelUSP.cpp TimeDate.o 
	$(CC) $(CFLAGS) RMlicelUSP.cpp

RMnetcdfUSP.o	:	RMnetcdfUSP.cpp RMlicelUSP.o TimeDate.o 
	$(CC) $(CFLAGS) RMnetcdfUSP.cpp

clean	:	
	rm -f *.o *~ 

clean-all	:	
	rm -f *.o *~ $(PROGS) *_cpp.d *.so

check	: $(PROGS)
	@echo -n "rm2dat :: dat conversion: "
	@./rm2dat RM1120200.012; TMP=`md5sum RM1120200.012.dat`; \
	if test "$$TMP" = "08c6f9cf5fd4c0748b5c74159ffbe796  RM1120200.012.dat" ; then \
		echo ok;\
		rm -f RM1120200.012.dat;\
	else\
		echo FAIL;\
	fi; 
	@echo -n "rm2csv :: csv conversion: "
	@./rm2csv RM1120200.012; TMP=`md5sum RM1120200.012.csv`; \
	if test "$$TMP" = "24a4e279077b5dacb8c74674404aded9  RM1120200.012.csv" ; then \
		echo ok;\
		rm -f RM1120200.012.csv;\
	else\
		echo FAIL;\
	fi; 
	@echo -n "rm2bin :: Averaging one file: "
	@rm -f teste1; ./rm2bin teste1 RM1120200.012; \
	TMP=`diff teste1 RM1120200.012`; \
	if test "x$$TMP" = "x" ; then \
		echo ok;\
		rm -f teste1;\
	else\
		echo FAIL;\
	fi; 
	@echo -n "rm2bin :: Averaging multiple files: "
	@rm -f teste2; ./rm2bin teste2 RM10C1315.???; \
	TMP=`md5sum teste2`; \
	if test "$$TMP" = "bd4c03d7a4c479a95320035e1e7c3590  teste2" ; then \
		echo ok;\
		rm -f teste2;\
	else\
		echo FAIL;\
	fi;
	@echo "rm2bin + rm2csv:: Averaging - hardcore testing: "
	@rm -f teste3; \
	./rm2bin teste3 RM10C1315.162 RM10C1315.172; \
	./rm2csv teste3 RM10C1315.162 RM10C1315.172; \
	nbin=`head -n 4 teste3.csv | tail -n 1 | sed s/\;/\\\n/g | head -n 4 | tail -n 1`; \
	nbin=`echo $$nbin + 0 | bc`; P=$$((nbin/25)); \
	echo "|0%                 100%| "; \
	i=0; ok=0; while read -r linA<&3 && read -r linB<&4 && read -r linC<&5; do \
		i=$$((i+1)); \
		if [ $$i -gt 8 ] ; then \
			A=`echo $$linA | sed s/\;/+/g | bc`; \
			B=`echo $$linB | sed s/\;/+/g | bc`; \
			C=`echo $$linC | sed s/\;/+/g | bc`; \
			if [ `echo \($$A+$$B\)/2 - $$C \> 0.0001 | bc` -eq 1 ] ; then \
				ok=1; echo "error averaging line #$$i "; \
				echo $$A + $$B / 2 != $$C ; \
				j=2; while [ $$j -le 6 ] ; do \
					A=`echo $$linA | sed s/\;/\\\n/g | head -n $$j | tail -n 1`; \
					B=`echo $$linB | sed s/\;/\\\n/g | head -n $$j | tail -n 1`; \
					C=`echo $$linC | sed s/\;/\\\n/g | head -n $$j | tail -n 1`; \
					if [ `echo \($$A+$$B\)/2 - $$C \> 0.0001 | bc` -eq 1 ] ; then \
						echo "error averaging line #$$i of column #$$j"; \
						echo $$A + $$B / 2 != $$C ; \
					fi; \
					j=$$((j+1)); \
				done; \
			fi; \
		fi;\
		if [ `echo $$((i-9)) % $$P | bc` -eq 0 ] ; then \
			echo -n ".";\
		fi;\
	done 3<"RM10C1315.162.csv" 4<"RM10C1315.172.csv" 5<"teste3.csv"; \
	if [ $$ok ] ; then \
		echo "ok"; \
		rm -f teste3 teste3.csv RM10C1315.162.csv RM10C1315.172.csv;\
	else echo ""; fi; \
#
