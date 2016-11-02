#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>

using namespace std;
using namespace cv;

extern "C" void gray_parallel(unsigned char* h_in, unsigned char* h_out, int elems, int rows, int cols);

int main(){

	Mat d_image;

	//checkCudaErrors(cudaFree(0));

	Mat image;
	image = imread("via.png",CV_LOAD_IMAGE_COLOR);

	namedWindow( "Display window", WINDOW_AUTOSIZE );
	imshow( "Display window", image );

	const int rows = image.rows;
	const int cols = image.cols;
	int elems = rows*cols*3;
	unsigned char *h_in = image.data;
	unsigned char *h_out = new unsigned char[rows*cols];

	gray_parallel(h_in, h_out, elems, rows, cols);

	Mat gray2 = Mat(rows,cols,CV_8UC1,h_out);

	namedWindow( "Display window GrayScale", WINDOW_AUTOSIZE );
	imshow( "Display window GrayScale", gray2 );
	waitKey(0);

	return 0;
}

__global__ void kernel(unsigned char* d_in, unsigned char* d_out, int w, int h){

    //int idx = blockIdx.x;
	//int idy = threadIdx.x;

	int col = blockIdx.x*blockDim.x + threadIdx.x;
	int row = blockIdx.y*blockDim.y + threadIdx.y;

	//int gray_adr = idx*w + idy;
	int gray_adr =row*w+col;
	int clr_adr = 3*gray_adr;

	if(gray_adr<(w*h))
		{
			double gray_val = 0.21f*d_in[clr_adr] + 0.71f*d_in[clr_adr+1] + 0.07f*d_in[clr_adr+2];
			d_out[gray_adr] = (unsigned char)gray_val;
			//printf(" %d:%d=[%d,%d,%d,%d] \n", idx,idy,d_in[clr_adr],d_in[clr_adr+1],d_in[clr_adr+2],(int)gray_val);
		}
}

//   Kernel Calling Function

extern "C" void gray_parallel(unsigned char* h_in, unsigned char* h_out, int elems, int rows, int cols){

	unsigned char* d_in;
	unsigned char* d_out;
	cudaMalloc((void**) &d_in, elems);
	cudaMalloc((void**) &d_out, rows*cols);

	dim3 dimBlock(96, 96, 1);
	dim3 dimGrid((cols-1)/96+1, (rows-1)/96+1, 1);

	cudaMemcpy(d_in, h_in, elems*sizeof(unsigned char), cudaMemcpyHostToDevice);
    //kernel<<<rows,cols>>>(d_in, d_out, cols, rows);
	kernel<<<dimBlock, dimGrid>>>(d_in, d_out, cols, rows);

	cudaError_t errSync  = cudaGetLastError();
	if (errSync != cudaSuccess)
  		printf("Sync kernel error: %s\n", cudaGetErrorString(errSync));

	cudaMemcpy(h_out, d_out, rows*cols*sizeof(unsigned char), cudaMemcpyDeviceToHost);
	cudaFree(d_in);
	cudaFree(d_out);
}
