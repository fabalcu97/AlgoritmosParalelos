#include <stdio.h>

/*	Multiplicación de Matrices
 *
 * Integrantes:
 *	-Fabricio Ballón Cuadros.
 *	-Angel Suacapuca Díaz.
*/

#define TILE_WIDTH 2

__global__ void MatrixMulKernel1(float* d_M, float* d_N, float* d_P, int Width) {
	// Calculate the row index of the d_P element and d_M
	int Row = blockIdx.y*blockDim.y+threadIdx.y;
	// Calculate the column index of d_P and d_N
	int Col = blockIdx.x*blockDim.x+threadIdx.x;
	if ((Row < Width) && (Col < Width)) {
		float Pvalue = 0;
		// each thread computes one element of the block sub-matrix
		for (int k = 0; k < Width; ++k) {
			Pvalue += d_M[Row*Width+k]*d_N[k*Width+Col];
		}
		d_P[Row*Width+Col] = Pvalue;
	}
}

__global__ void MatrixMulKernel(float *d_M, float *d_N, float *d_P, int Width) {
	__shared__ float Mds[TILE_WIDTH][TILE_WIDTH];
	__shared__ float Nds[TILE_WIDTH][TILE_WIDTH];
	int bx = blockIdx.x;
	int by = blockIdx.y;
	int tx = threadIdx.x;
	int ty = threadIdx.y;

	// Identify the row and column of the d_P element to work on
	int Row = by * TILE_WIDTH + ty;
	int Col = bx * TILE_WIDTH + tx;
	float Pvalue = 0;

	// Loop over the d_M and d_N tiles required to compute d_P element
	for (int m = 0; m < Width / TILE_WIDTH; ++m) {
	// Coolaborative loading of d_M and d_N tiles into shared memory
		Mds[ty][tx] = d_M[Row * Width + m * TILE_WIDTH + tx];
		Nds[ty][tx] = d_N[(m * TILE_WIDTH + ty) * Width + Col];
		__syncthreads();
		for (int k = 0; k < TILE_WIDTH; ++k) {
			Pvalue += Mds[ty][k] * Nds[k][tx];
		}
		__syncthreads();
	}
	d_P[Row * Width + Col] = Pvalue;
}

__host__ int main(int argc, char const *argv[]) {

	float *h_M;
	float *h_N;
	float *h_P;
	float *d_M;
	float *d_N;
	float *d_P;
	int width = atoi(argv[1]);
	int size = width * width * sizeof(float);

	h_M = (float*)malloc(size);
	h_N = (float*)malloc(size);
	h_P = (float*)malloc(size);

	for (size_t i = 0; i < width*width; i++) {
		h_M[i] = 1;
		h_N[i] = 1;
	}

	cudaMalloc((void**) &d_M, size);
	cudaMalloc((void**) &d_N, size);
	cudaMalloc((void**) &d_P, size);

	cudaMemcpy(d_M, h_M, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_N, h_N, size, cudaMemcpyHostToDevice);

	dim3 dimBlock(16, 16, 1);
	dim3 dimGrid((width-1)/16+1, (width-1)/16+1, 1);

	MatrixMulKernel1<<<dimBlock, dimGrid>>>(d_M, d_N, d_P, width);

	cudaMemcpy(h_P, d_P, size, cudaMemcpyDeviceToHost);

	printf("\n");
	for (size_t i = 0; i < width*width; i++) {
		printf("%6f--", h_P[i]);
	}
	printf("\n");

	return 0;
}
