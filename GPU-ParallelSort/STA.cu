#include<iostream>
#include <thrust/sort.h>

using namespace std;

int main(int argc, char const *argv[]) {

	int numOfArrays = atoi(argv[1]);
	int maxElements = atoi(argv[2]);

	int N = numOfArrays*maxElements;
	float *data = new float[numOfArrays*maxElements];
	float *keys = new float[numOfArrays*maxElements];

	for(int i = 0; i < numOfArrays; i++){
		for(int j = 0; j < maxElements; j++){
			data [j+i*maxElements] = rand() % 501;
			keys [j+i*maxElements] = i;
		}
	}

	clock_t firstKrTime = clock();

	thrust::sort_by_key(data, data+N, keys);

	firstKrTime = clock()-firstKrTime;

	clock_t secondKrTime = clock();

	thrust::sort_by_key(keys, keys+N, data);

	secondKrTime = clock()-secondKrTime;

	cout<<(firstKrTime+secondKrTime)/double(CLOCKS_PER_SEC)*1000<<endl;


	free(data);
	free(keys);
	return 0;
}
