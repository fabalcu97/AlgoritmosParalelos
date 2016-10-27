#include <stdio.h>

using namespace std;

#define BLOCK_SIZE 16
#define GRID_SIZE 1

__global__
void GScale(float* img, int iRow, int iCol, int id){

	int col = blockIdx.x*blockDim.x + threadIdx.x;
	int row = blockIdx.y*blockDim.y + threadIdx.y;
	int a = blockIdx.z*blockDim.z + threadIdx.z;

	if (col < iCol && row < iRow && a < id){

		img[row*iCol+col+a*iRow*iCol]=2*img[row*iCol+col+a*iRow*iCol];
	}
}

__host__
int main(void)
{
  int N = 60;
  float *x, *d_x;

  x = (float*)malloc(N*N*N*sizeof(float));

  cudaMalloc(&d_x, N*N*N*sizeof(float));

  for (int i = 0; i < N*N*N; i++) {
    x[i] = 1.0f;
  }

	dim3 dimBlock(16,16,16);
	dim3 dimGrid((N-1)/16+1, (N-1)/16+1, (N-1)/16+1);

  cudaMemcpy(d_x, x, N*N*N*sizeof(float), cudaMemcpyHostToDevice);

  GScale<<<dimGrid, dimBlock>>>(&d_x, N, N, N);

  cudaMemcpy(x, d_x, N*N*N*sizeof(float), cudaMemcpyDeviceToHost);

  	for (int i = 0; i < N*N*N; i++){
		printf("%f - ", x[i]);
	}

}
