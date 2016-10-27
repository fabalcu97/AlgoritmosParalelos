#include <stdio.h>
#include <math.h>

__global__
void saxpy(int n, float *x, float *y, float *c)
{
	int i = blockIdx.x*blockDim.x + threadIdx.x;

	if (i < n){
		c[i] = x[i] + y[i];
	}
}

__host__
int main(void)
{

	int N = 300;
	float *x, *y, *c, *d_x, *d_y, *d_c;

	x = (float*)malloc(N*sizeof(float));
	y = (float*)malloc(N*sizeof(float));
	c = (float*)malloc(N*sizeof(float));

	cudaMalloc( (void**) &d_x, N*sizeof(float));
	cudaMalloc( (void**) &d_y, N*sizeof(float));
	cudaMalloc( (void**) &d_c, N*sizeof(float));

	for (int i = 0; i < N; i++) {
		x[i] = 1.0f;
		y[i] = 2.0f;
	}

	cudaMemcpy(d_x, x, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, N*sizeof(float), cudaMemcpyHostToDevice);

	saxpy<<<1, N>>>(N, d_x, d_y, d_c);

	cudaMemcpy(c, d_c, N*sizeof(float), cudaMemcpyDeviceToHost);

	// float maxError = 0.0f;

	for (int i = 0; i < N; i++){
		printf("%f - ", c[i]);
	}

	//   maxError = max(maxError, abs(y[i]-4.0f));
	// printf("Max error: %f\n", maxError);
}
