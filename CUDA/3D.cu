#include <stdio.h>

using namespace std;

#define BLOCK_SIZE 16
#define GRID_SIZE 1

__global__
void GScale(float* img, float* res, int iRow, int iCol, int id){

	int col = blockIdx.x*blockDim.x + threadIdx.x;
	int row = blockIdx.y*blockDim.y + threadIdx.y;
	int a = blockIdx.z*blockDim.z + threadIdx.z;

	if (col < iCol && row < iRow && a<id){

		res[row*iCol+col+a*iCol*iRow]=2.0*img[row*iCol+col+a*iCol*iRow];
	}
}

__host__
int main(void)
{
  int N = 6;
  float *x, *y, *d_x, *d_y;

  x = (float*)malloc(N*N*N*sizeof(float));
  y = (float*)malloc(N*N*N*sizeof(float));

  cudaMalloc((void**)&d_x, N*N*N*sizeof(float));
  cudaMalloc((void**)&d_y, N*N*N*sizeof(float));

  for (int i = 0; i < N*N*N; i++) {
    x[i] = 5.0;
	//y[i] = 0.0;
  }

	dim3 dimBlock(16,16,16);
	dim3 dimGrid((N-1)/16+1, (N-1)/16+1, (N-1)/16+1);
	//dim3 dimGrid(1, 1, 1);


  cudaMemcpy(d_x, x, N*N*N*sizeof(float), cudaMemcpyHostToDevice);

  GScale<<<dimBlock, dimGrid>>>(d_x, d_y, N, N, N);

  cudaMemcpy(y, d_y, N*N*N*sizeof(float), cudaMemcpyDeviceToHost);

  	for (int i = 0; i < N*N*N; i++){
		printf("%f - ", y[i]);
	}

	cudaFree(d_x);
	cudaFree(d_y);

}
