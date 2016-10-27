#include "bitmap_image.hpp"

__global__
void GScale(bitmap_image* img, int iRow, int iCol){

	int col = blockIdx.x*blockDim.x + threadIdx.x;
	int row = blockIdx.y*blockDim.y + threadIdx.y;

	if (col < iCol && row < iRow){
		img.set_pixel(col, row, 0.07, 0.71, 0.21);
	}
}

int main(int argc, char const *argv[]) {

	bitmap_image image("input.bmp");

	if (!image)
	{
		printf("Error - Failed to open: input.bmp\n");
		return 1;
	}

	image.save_image("output.bmp");
	return 0;
}
