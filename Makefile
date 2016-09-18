MPIC++ = mpic++
G++ = g++
GCC = gcc
CFLAGS = -o main.o -pthread
CXXFLAGS = -std=c++11 -o main.o -pthread

ej3-5:
	$(GCC) $(FLAGS) Ej3-5.cpp
	mpiexec -n 4 main.o 200

GlobSum:
	$(G++) $(CXXFLAGS) $(THRD) pThreads/global_sum.cpp
	./main.o 4 50

pmxv:
	$(GCC) $(CFLAGS) pThreads/MxV/main.c
	@echo "8000000x8"
	@./main.o 1 8000000 8
	@./main.o 2 8000000 8
	@./main.o 4 8000000 8
	@./main.o 8 8000000 8
	@echo "8000x8000"
	@./main.o 1 8000 8000
	@./main.o 2 8000 8000
	@./main.o 4 8000 8000
	@./main.o 8 8000 8000
	@echo "8x8000000"
	@./main.o 1 8 8000000
	@./main.o 2 8 8000000
	@./main.o 4 8 8000000
	@./main.o 8 8 8000000

clean:
	rm *.o
