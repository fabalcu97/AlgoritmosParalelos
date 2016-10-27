#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

using namespace std;
using namespace cv;

__global__
void GScale(Vec3b* img, int iRow, int iCol){

	int col = blockIdx.x*blockDim.x + threadIdx.x;
	int row = blockIdx.y*blockDim.y + threadIdx.y;

	if (col < iCol && row < iRow){

		img[row][col][0] *= 0.07f;		//BLUE
		img[row][col][1] *= 0.71f;		//GREEN
		img[row][col][2] *= 0.21f;		//RED
	}
}

int main(){

	Mat d_image;

	Mat image;
	image = imread("tux.bmp", CV_LOAD_IMAGE_COLOR);

	namedWindow( "Display window", WINDOW_AUTOSIZE );
	imshow( "Display window", image );

	Vec3b aa;
	Vec3b d_aa;

	for(int y = 0; y < image.rows; y++) {
		Vec3b tmp;
		for(int x = 0; x < image.cols; x++) {
			tmp.push_back(image.at<Vec3b>(y, x));
		}
		aa.push_back(tmp);
	}

	cudaMalloc( (void**) &d_aa, sizeof(Mat));
	cudaMemcpy(&d_aa, &aa, sizeof(uchar * image.rows * image.cols), cudaMemcpyHostToDevice);

	/* for(int y = 0; y < image.rows; y++) {
		for(int x = 0; x < image.cols; x++) {
			image.at<Vec3b>(y, x)[0] *= 0.3;		//BLUE
			image.at<Vec3b>(y, x)[1] *= 0.3;		//GREEN
			image.at<Vec3b>(y, x)[2] *= 0.3;		//RED
		}
	}
	*/

	GScale<<<1, 96>>>(&aa, image.rows, image.cols);
	cudaMemcpy(&aa, &d_aa, sizeof(uchar * image.rows * image.cols), cudaMemcpyDeviceToHost);


	namedWindow( "Display window GrayScale", WINDOW_AUTOSIZE );
	imshow( "Display window GrayScale", image );
	waitKey(0);

	return 0;
}
