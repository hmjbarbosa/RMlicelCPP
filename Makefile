
OBJ=\
	RMlicelUSP.o

PROGS=\
	dataread \
	rm2bin \
	rm2csv \
	rm2dat

CC=g++

CFLAGS=-g -Wall

all	:	$(PROGS)

rm2bin	:	rm2bin.cpp $(OBJ)
	$(CC) -o rm2bin $(CFLAGS) $(OBJ) rm2bin.cpp

rm2csv	:	rm2csv.cpp $(OBJ)
	$(CC) -o rm2csv $(CFLAGS) $(OBJ) rm2csv.cpp

rm2dat	:	rm2dat.cpp $(OBJ)
	$(CC) -o rm2dat $(CFLAGS) $(OBJ) rm2dat.cpp

dataread	:	dataread.cpp $(OBJ)
	$(CC) -o dataread $(CFLAGS) $(OBJ) $<

RMlicelUSP.o	:	RMlicelUSP.cpp
	$(CC) -c $(CFLAGS) RMlicelUSP.cpp

clean	:	
	rm -f $(OBJ) 
	rm -f *~

clean-all	:	
	rm -f $(OBJ) 
	rm -f $(PROGS)
	rm -f *~
