CC=g++-12
# 2-july-2020
# apparently fbounds-check is meant only for F77 and Java
# 
CHECK=-fcheck-new -Wextra -ftrapv -fstack-check 
#CHECK=-fbounds-check -fcheck-new -Wextra -ftrapv -fstack-check 
#CHECK=-fbounds-check -Wextra -ftrapv 
CFLAGS=-c -Wall -O0  -g $(CHECK) 
LFLAGS=-Wall -O0  $(CHECK) 

#NETCDF=-L/usr/local/lib -lnetcdf -I/usr/local/include
NETCDF_INC=-I/opt/homebrew/include
NETCDF_LIB=-L/opt/homebrew/lib -lnetcdf 
# -pthread -static testing.cpp -lnetcdf -lhdf5_hl -lhdf5 -lz  -lm -lcurl -lidn -llber -lldap -lrt -lgssapi_krb5 -lssl -lcrypto -lz -static-libstdc++ -static-libgcc

PROGS=\
	rm2nclist \
	rm2bin \
	rm2csv \
	rm2dat \
	rm2nc \
	rm2name

all	:	$(PROGS)

tarball	:
	@mydir=`basename $$PWD`; cd ..;\
	ofile=$$mydir'_'`date +%Y%b%d`'.tgz';\
	tar -czvf $$ofile $$mydir/*.h $$mydir/*.cpp $$mydir/RM* $$mydir/ipen* \
		$$mydir/arg* $$mydir/Makefile $$mydir/README

rm2name	:	rm2name.cpp TimeDate.o RMlicel.o
	$(CC) $(LFLAGS) -o rm2name rm2name.cpp TimeDate.o RMlicel.o

rm2bin	:	rm2bin.cpp TimeDate.o RMlicel.o
	$(CC) $(LFLAGS) -o rm2bin rm2bin.cpp TimeDate.o RMlicel.o

rm2csv	:	rm2csv.cpp TimeDate.o RMlicel.o
	$(CC) $(LFLAGS) -o rm2csv rm2csv.cpp  TimeDate.o RMlicel.o

rm2dat	:	rm2dat.cpp TimeDate.o RMlicel.o
	$(CC) $(LFLAGS) -o rm2dat rm2dat.cpp  TimeDate.o RMlicel.o

rm2nclist	:	rm2nclist.cpp TimeDate.o RMlicel.o RMnetcdf.o
	$(CC) $(LFLAGS) $(NETCDF_LIB) $(NETCDF_INC) -o rm2nclist rm2nclist.cpp TimeDate.o RMlicel.o RMnetcdf.o 

rm2nc	:	rm2nc.cpp TimeDate.o RMlicel.o RMnetcdf.o
	$(CC) $(LFLAGS) $(NETCDF_LIB) $(NETCDF_INC) -o rm2nc rm2nc.cpp TimeDate.o RMlicel.o RMnetcdf.o

TimeDate.o	:	TimeDate.cpp
	$(CC) $(CFLAGS) TimeDate.cpp

RMlicel.o	:	RMlicel.cpp TimeDate.o 
	$(CC) $(CFLAGS) RMlicel.cpp

RMnetcdf.o	:	RMnetcdf.cpp RMlicel.o TimeDate.o 
	$(CC) $(CFLAGS) $(NETCDF_INC) RMnetcdf.cpp 

clean	:	
	rm -fR *.o *~ *.dSYM

clean-all	:	
	rm -fR *.o *~ *.dSYM $(PROGS) *_cpp.d *.so

check	: $(PROGS)
	@echo -n "TEST #1 :: rm2dat :: dat conversion: "
	@rm -f RM1120200.012.dat > /dev/null; \
	./rm2dat RM1120200.012; TMP=`md5sum RM1120200.012.dat`; \
	if test "$$TMP" = "08c6f9cf5fd4c0748b5c74159ffbe796  RM1120200.012.dat" ; then \
		echo ok;\
		rm -f RM1120200.012.dat;\
	else echo FAIL;	fi; 
	@echo -n "TEST #2 :: rm2csv :: csv conversion: "
	@rm -f RM1120200.012.csv > /dev/null; \
	./rm2csv RM1120200.012; TMP=`md5sum RM1120200.012.csv`; \
	if test "$$TMP" = "24a4e279077b5dacb8c74674404aded9  RM1120200.012.csv" ; then \
		echo ok;\
		rm -f RM1120200.012.csv;\
	else echo FAIL;	fi; 
	@echo -n "TEST #3 :: rm2bin :: Copying one file: "
	@rm -f test3 > /dev/null; ./rm2bin test3 RM1120200.012; \
	TMP=`diff test3 RM1120200.012`; \
	if test "x$$TMP" = "x" ; then \
		echo ok;\
		rm -f test3;\
	else echo FAIL; fi; 
	@echo -n "TEST #4 :: rm2bin :: Copying one file from Argentina: "
	@rm -f test4 test4_crop test4_crop2 > /dev/null;\
	./rm2bin test4 argentina_lidar_b1230700.005373; \
	tail -n +3 test4 > test4_crop; tail -n +3 argentina_lidar_b1230700.005373 > test4_crop2;\
	TMP=`diff test4_crop test4_crop2`; \
	if test "x$$TMP" = "x" ; then \
		echo ok;\
		rm -f test4 test4_crop test4_crop2;\
	else echo FAIL; fi; 
	@echo -n "TEST #5 :: rm2bin :: Averaging multiple files: "
	@rm -f test5 > /dev/null; ./rm2bin test5 RM10C1315.???; \
	TMP=`md5sum test5`; \
	if test "$$TMP" = "bd4c03d7a4c479a95320035e1e7c3590  test5" ; then \
		echo ok;\
		rm -f test5;\
	else echo FAIL; fi;
	@echo -n "TEST #6 :: rm2bin :: Averaging multiple IPEN files: "
	@rm -f test6 > /dev/null; ./rm2bin test6 ipen_RM1291010.???; \
	TMP=`md5sum test6`; \
	if test "$$TMP" = "9c4eea03d92b9e039e061d13f40dc1be  test6" ; then \
		echo ok;\
		rm -f test6;\
	else echo FAIL; fi;
	@echo -n "TEST #7 :: rm2nc  :: Converting single file to netCDF: "
	@rm -f RM10C1315.162.nc > /dev/null; ./rm2nc RM10C1315.162; \
	TMP=`md5sum RM10C1315.162.nc`; \
	if test "$$TMP" = "389ee62a475d98a0c54fe7d86beabf9d  RM10C1315.162.nc" ; then \
		echo ok;\
		rm -f RM10C1315.162.nc;\
	else echo FAIL; fi;
	@echo -n "TEST #8 :: rm2nc  :: Converting single Argentina file to netCDF: "
	@rm -f argentina_lidar_b1230700.005373.nc > /dev/null; ./rm2nc argentina_lidar_b1230700.005373; \
	TMP=`md5sum argentina_lidar_b1230700.005373.nc`; \
	if test "$$TMP" = "52b3e32b999b05eb7858afb8b68bd3ed  argentina_lidar_b1230700.005373.nc" ; then \
		echo ok;\
		rm -f argentina_lidar_b1230700.005373.nc;\
	else echo FAIL; fi;
	@echo -n "TEST #9 :: rm2list:: Converting IPEN files to netCDF list: "
	@rm -f test9.nc > /dev/null; ./rm2nclist test9 ipen_RM1291010.162 ipen_RM1291010.181; \
	TMP=`md5sum test9.nc`; \
	if test "$$TMP" = "16a5590ae8b0e1b742b5acd87f27458b  test9.nc" ; then \
		echo ok;\
		rm -f test9.nc;\
	else echo FAIL; fi;
	@echo "TEST #10 :: rm2bin + rm2csv:: Averaging 2 files, hardcore testing: "
	@rm -f test10 test10.csv RM10C1315.162.csv RM10C1315.172.csv > /dev/null; \
	./rm2bin test10 RM10C1315.162 RM10C1315.172; \
	./rm2csv test10 RM10C1315.162 RM10C1315.172; \
	nbin=`head -n 4 test10.csv | tail -n 1 | awk '{print $$7}'`; \
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
	done 3<"RM10C1315.162.csv" 4<"RM10C1315.172.csv" 5<"test10.csv"; \
	if [ $$ok ] ; then \
		echo "ok"; \
		rm -f test10 test10.csv RM10C1315.162.csv RM10C1315.172.csv;\
	else echo FAIL; fi; 
	@echo "TEST #11 :: rm2bin + rm2csv:: Averaging - hardcore testing on IPEN files: ";
	@rm -f test11; \
	./rm2bin test11 ipen_RM1291010.162 ipen_RM1291010.181; \
	./rm2csv test11 ipen_RM1291010.162 ipen_RM1291010.181; \
	nbin=`head -n 4 test11.csv | tail -n 1 | sed s/\;/\\\n/g | head -n 4 | tail -n 1`; \
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
	done 3<"ipen_RM1291010.162.csv" 4<"ipen_RM1291010.181.csv" 5<"test11.csv"; \
	if [ $$ok ] ; then \
		echo "ok"; \
		rm -f test11 test11.csv ipen_RM1291010.162.csv ipen_RM1291010.181.csv;\
	else echo ""; fi; \
#
