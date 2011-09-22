
EXEC=dataread

OBJ=\
	dataread.o \
	RMlicelUSP.o

CC=g++

CFLAGS=-g -Wall
FFLAGS=

dataread	:	$(OBJ)
	$(CC) -o $(EXEC) $(LFLAGS) $(OBJ)

dataread.o	:	dataread.cpp RMlicelUSP.o
	$(CC) -c $(CFLAGS) dataread.cpp

RMlicelUSP.o	:	RMlicelUSP.cpp
	$(CC) -c $(CFLAGS) RMlicelUSP.cpp

Char.o	:	Char.cpp
	$(CC) -c $(CFLAGS) Char.cpp

clean	:	
	rm -f $(OBJ)
	rm -f $(EXEC)
