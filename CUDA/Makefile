#####Variables######

# Compilador
CXX = g++
NVCC = nvcc

#Opciones de compilación
CXXFLAGS = -std=c++11 -o main.o
NVFLAGS = -lcudart -o main.o

#Opciones de subida

m1:
	# @$(NVCC) $(NVFLAGS) vect_sum.cu
	@$(NVCC) $(NVFLAGS) hw.cu
	@./main.o
