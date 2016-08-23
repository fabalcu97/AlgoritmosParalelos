CC = g++
CFLAGS = -std=c++11 -o main.o -Wall

Matrix_6loop:
	$(CC) $(CFLAGS) Matrix_6loop.cpp
	./main.o


Matrix_3loop:
	$(CC) $(CFLAGS) Matrix_3loop.cpp
	./main.o

execute:
	./main.o

clean:
	rm *.o
