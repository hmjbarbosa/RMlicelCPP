CC=g++
CFLAGS=-c -Wall -O0 -g
LFLAGS=-Wall -O0 -g

PROGS=\
	dataread \
	rm2bin \
	rm2csv \
	rm2dat \
	rm2nc \
	debug

all	:	$(PROGS)

debug	:	debug.cpp TimeDate.o RMlicelUSP.o
	$(CC) $(LFLAGS) -o debug debug.cpp TimeDate.o RMlicelUSP.o

rm2bin	:	rm2bin.cpp TimeDate.o RMlicelUSP.o
	$(CC) $(LFLAGS) -o rm2bin rm2bin.cpp TimeDate.o RMlicelUSP.o

rm2csv	:	rm2csv.cpp TimeDate.o RMlicelUSP.o
	$(CC) $(LFLAGS) -o rm2csv rm2csv.cpp  TimeDate.o RMlicelUSP.o

rm2dat	:	rm2dat.cpp TimeDate.o RMlicelUSP.o
	$(CC) $(LFLAGS) -o rm2dat rm2dat.cpp  TimeDate.o RMlicelUSP.o

dataread	:	dataread.cpp TimeDate.o RMlicelUSP.o RMnetcdfUSP.o
	$(CC) $(LFLAGS) -lnetcdf -o dataread dataread.cpp TimeDate.o RMlicelUSP.o RMnetcdfUSP.o

rm2nc	:	rm2nc.cpp TimeDate.o RMlicelUSP.o RMnetcdfUSP.o
	$(CC) $(LFLAGS) -lnetcdf -o rm2nc rm2nc.cpp TimeDate.o RMlicelUSP.o RMnetcdfUSP.o

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
	else\
		echo FAIL;\
	fi; rm -f RM1120200.012.dat; 
	@echo -n "rm2csv :: csv conversion: "
	@./rm2csv RM1120200.012; TMP=`md5sum RM1120200.012.csv`; \
	if test "$$TMP" = "24a4e279077b5dacb8c74674404aded9  RM1120200.012.csv" ; then \
		echo ok;\
	else\
		echo FAIL;\
	fi; rm -f RM1120200.012.csv; 
	@echo -n "rm2bin :: Averaging one file: "
	@rm -f teste; ./rm2bin teste RM1120200.012; \
	TMP=`diff teste RM1120200.012`; \
	if test "x$$TMP" = "x" ; then \
		echo ok;\
	else\
		echo FAIL;\
	fi; rm -f teste;
	@echo -n "rm2bin :: Averaging multiple files: "
	@rm -f teste; ./rm2bin teste RM10C1315.???; \
	TMP=`md5sum teste`; \
	if test "$$TMP" = "ab0a01b7f8fda2abbcd7132208680c27  teste" ; then \
		echo ok;\
	else\
		echo FAIL;\
	fi; rm -f teste;
	@echo "rm2bin + rm2csv:: Averaging - hardcore testing: "
	@rm -f teste; \
	./rm2bin teste RM10C1315.162 RM10C1315.172; \
	./rm2csv teste RM10C1315.162 RM10C1315.172; \
	nbin=`head -n 4 teste.csv | tail -n 1 | sed s/\;/\\\n/g | head -n 4 | tail -n 1`; \
	nbin=`echo $$nbin + 9| bc`; part=$$((nbin/10)); \
	echo $$nbin $$part; \
	j=2; while [ $$j -le 6 ] ; do \
		echo -n "averaging column $$((j-1))... "; \
		i=9; while [ $$i -le $$nbin ] ; do \
			A=`head -n $$i RM10C1315.162.csv | tail -n 1 | sed s/\;/\\\n/g | head -n $$j | tail -n 1`; \
			B=`head -n $$i RM10C1315.172.csv | tail -n 1 | sed s/\;/\\\n/g | head -n $$j | tail -n 1`; \
			C=`head -n $$i teste.csv         | tail -n 1 | sed s/\;/\\\n/g | head -n $$j | tail -n 1`; \
			if [ `echo \($$A+$$B\)/2 - $$C \> 0.0001 | bc` -eq 1 ] ; then \
				echo "error averaging line #$$i of column #$$j"; \
				echo $$A + $$B / 2 != $$C ; \
			fi; \
			if [ `echo $$i % $$part | bc` -eq 0 ] ; then \
				echo -n "$$i...";\
			fi;\
			i=$$((i+1)); \
		done; \
		echo "ok"; \
		j=$$((j+1)); \
	done; \
	rm -f teste teste.csv RM10C1315.162.csv RM10C1315.172.csv;

#
