#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>

using namespace std;
using namespace cv;

__global__
void GScale(unsigned char*  d_a, unsigned char* d_b, int iRow, int iCol){

	int col = blockIdx.x*blockDim.x + threadIdx.x;
	int row = blockIdx.y*blockDim.y + threadIdx.y;

	if (col < iCol && row < iRow){
		int clr_adr=(row*iCol+col)*3;
		/*img[row][col][0] *= 0.07f;		//BLUE
		img[row][col][1] *= 0.71f;		//GREEN
		img[row][col][2] *= 0.21f;		//RED*/
		double gray_val = 0.21f*d_a[clr_adr] + 0.71f*d_a[clr_adr+1] + 0.07f*d_a[clr_adr+2];
		d_b[(row*iCol+col)] = (unsigned char)gray_val;
		d_b[0]=(unsigned char)100.0;
	}
}

int main(){

	Mat d_image;

	//checkCudaErrors(cudaFree(0));

	Mat image;
	image = imread("input.bmp",CV_LOAD_IMAGE_COLOR);

	namedWindow( "Display window", WINDOW_AUTOSIZE );
	imshow( "Display window", image );

	unsigned char *a,*b,*d_a,*d_b;

	a = (unsigned char*)malloc(60*50*sizeof(unsigned char));
	b = (unsigned char*)malloc(60*50*sizeof(unsigned char));

	cudaMalloc((void**)&d_a, 60*50*3);
    cudaMalloc((void**)&d_b, 60*50);

	a=image.data;

	cudaMemcpy(&d_a, &a, sizeof(unsigned char)* 3 * 60 * 50, cudaMemcpyHostToDevice);

	/* for(int y = 0; y < image.rows; y++) {
		for(int x = 0; x < image.cols; x++) {
			image.at<Vec3b>(y, x)[0] *= 0.3;		//BLUE
			image.at<Vec3b>(y, x)[1] *= 0.3;		//GREEN
			image.at<Vec3b>(y, x)[2] *= 0.3;		//RED
		}
	}
	*/

	for(int i = 0; i < image.rows*image.cols; i++)
		printf("%d  - ",a[i]);

	dim3 dimBlock(26,26,1);
	dim3 dimGrid((50-1)/26+1, (60-1)/26+1, 1);

	GScale<<<60, 50>>>(d_a, d_b, 60, 50);

	cudaError_t errSync  = cudaGetLastError();
	if (errSync != cudaSuccess)
  		printf("Sync kernel error: %s\n", cudaGetErrorString(errSync));

	cudaMemcpy(&b, &d_b, sizeof(uchar) * 60 * 50, cudaMemcpyDeviceToHost);

	printf("%d\n",b[0]);

	for(int i = 0; i < image.rows*image.cols; i++)
		printf("%d  - ",b[i]);

	Mat gray = Mat(image.rows, image.cols, CV_8UC1, b);

	cudaFree(d_a);
	cudaFree(d_b);

	namedWindow( "Display window GrayScale", WINDOW_AUTOSIZE );
	imshow( "Display window GrayScale", gray );
	waitKey(0);

	return 0;
}
