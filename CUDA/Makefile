#####Variables######

# Compilador
CXX = g++
NVCC = nvcc

OPENCV = OPENCV = -I/usr/include/opencv -lopencv_calib3d -lopencv_contrib -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_gpu -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_nonfree -lopencv_objdetect -lopencv_photo -lopencv_stitching -lopencv_superres -lopencv_ts -lopencv_video -lopencv_videostab -lGL -lGLU -lrt -lpthread -lm -ldl

#Opciones de compilación
CXXFLAGS = -std=c++11 -o main.o
NVFLAGS = -lcudart -o main.o

#Opciones de subida

m1:
	# @$(NVCC) $(NVFLAGS) vect_sum.cu
	@$(NVCC) $(NVFLAGS) hw.cu
	@./main.o

m2:
	# @$(NVCC) $(NVFLAGS) vect_sum.cu
	@$(NVCC) $(NVFLAGS) $(OPENCV) IMG/img1.cu
	@mv main.o IMAG/main.o
	# @./main.o
