GCC = mpic++
FLAGS = -std=c++11 -o main.o

ej3-5:
	$(GCC) $(FLAGS) Ej3-5.cpp
	mpiexec -n 4 main.o 200
