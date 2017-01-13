NVCC = nvcc
#NVCCFLAGS = -std=c++11 -arch=sm_35 -DnumOfArrays=<number of arrays> -DmaxElements=<maximum number of elements per array> GPU-ArraySort.cu -o out
NVCCFLAGS = -std=c++11 -o a.out

arraysort:
	$(NVCC) $(NVCCFLAGS) GPU-ArraySort.cu
	sudo ./a.out

sta:
	$(NVCC) $(NVCCFLAGS) STA.cu
	sudo ./a.out 50000 1000
	# for run in {1..15}; do ./a.out 50000 1000 ; done
	# for run in {1..15}; do ./a.out 50000 2000 ; done
	# for run in {1..15}; do ./a.out 50000 3000 ; done
	# for run in {1..15}; do ./a.out 50000 4000 ; done

specs:
	@$(NVCC) $(NVCCFLAGS) getSpecs.cu
	@sudo ./a.out
