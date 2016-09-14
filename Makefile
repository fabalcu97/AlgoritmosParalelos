MPIC++ = mpic++
G++ = g++
CFLAGS =
CXXFLAGS = -std=c++11 -o main.o
THRD = -lpthread

ej3-5:
	$(GCC) $(FLAGS) Ej3-5.cpp
	mpiexec -n 4 main.o 200

GlobSum:
	$(G++) $(CXXFLAGS) $(THRD) pThreads/global_sum.cpp
	./main.o 4 50

clean:
	rm *.o
