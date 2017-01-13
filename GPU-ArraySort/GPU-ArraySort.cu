
/*
compile using :

nvcc -std=c++11 -arch=sm_35 -DnumOfArrays=<number of arrays> -DmaxElements=<maximum number of elements per array> GPU-ArraySort.cu -o out


*/


/*
Copyright (C) Muaaz Gul Awan and Fahad Saeed
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/



#include<iostream>
#include<vector>
#include<stdlib.h>
#include<time.h>
#include<math.h>
#include<ctime>
#include<algorithm>
#include<utility>
#include <curand.h>
#include <curand_kernel.h>
#include<random>
using namespace std;

#define numOfArrays 50000
#define maxElements 4000
// #define numOfArrays 5
// #define maxElements 20
#define tempo 2
#define m 20
#define BUCKETS (maxElements/m)
#define sampleRate 10
#define SAMPLED (sampleRate*maxElements)/100
#define BLOCK_SIZE 1024

//data generation
template <typename mType>
struct dataArrays{
	vector<mType> dataList;
	int *prefixArray;
};


/* template <typename type>
dataArrays<type> dataGen (int numOfArrays, int maxArraySize, int minArraySize){

   dataArrays<int> data;
   data.prefixArray = new int[numOfArrays+1]; //exclusive prefix scan
   const int range_from = 0;
   const unsigned int range_to = 30;//2147483647; //2^31 - 1
   random_device rand_dev;
   mt19937 generator(rand_dev());
   uniform_int_distribution<int> distr(range_from, range_to);
   int prefixSum = 0;
   srand(time(0));
	for( int i = 0; i < numOfArrays; i++){

		int size = rand()%(maxArraySize-minArraySize + 1) + minArraySize;
		data.prefixArray[i] = prefixSum;
		for(int j = prefixSum; j < prefixSum + size; j++){
			data.dataList.push_back(distr(generator));
		}
		prefixSum += size;
	}

	data.prefixArray[numOfArrays] = prefixSum;
	return data;
} */


//swap function for Insertion sort
template <class type>
 __device__ void  swapD (type &a, type &b)

{
    /* &a and &b are reference variables */
    type temp;
        temp=a;
	a=b;
        b=temp;
}

//insertion sort
template <class type>
 __device__ void insertionSort(type *input, int begin, int end){
        int i, j; //,tmp;
        for (i = begin+1; i < end; i++) {
            j = i;
            while (j > begin && input[j - 1] > input[j]) {
                  swapD(input[j], input[j-1]);
                   j--;
                 }//end of while loop
           }
        }

__device__ int left(int index) {
		return (index << 1) + 1;
}
/*
template <typename type>
__device__ void maxSiftDown(type *array,int fromIndex, int toIndex, int index) {
	   int leftChildIndex = left(index);
	   // Right child index is one position from left child index towards
	   // larger indices.
	   int rightChildIndex = leftChildIndex + 1;
	   int maxChildIndex = index;
	   // Save the array component we want to sift down.
	   int target = array[fromIndex + index];

	   for (;;) {
		   if (fromIndex + leftChildIndex < toIndex
				   && array[fromIndex + leftChildIndex] > target) {
			   maxChildIndex = leftChildIndex;
		   }

		   if (maxChildIndex == index) {
			   if (fromIndex + rightChildIndex < toIndex
					   && array[fromIndex + rightChildIndex] > target) {
				   maxChildIndex = rightChildIndex;
			   }
		   } else {
			   if (fromIndex + rightChildIndex < toIndex
					   && array[fromIndex + rightChildIndex] >
						  array[fromIndex + leftChildIndex]) {
				   maxChildIndex = rightChildIndex;
			   }
		   }

		   if (maxChildIndex == index) {
			   // No swap. Just insert the sifted element.
			   array[fromIndex + maxChildIndex] = target;
			   return;
		   }

		   // No swap here neither.
		   // Just move up the maximum to current position.
		   array[fromIndex + index] = array[fromIndex + maxChildIndex];

		   index = maxChildIndex;
		   leftChildIndex = left(index);
		   rightChildIndex = leftChildIndex + 1;
	   }
}

template <class type>
 __device__ void buildMaxHeap(type *array, int fromIndex, int toIndex) {
    int rangeLength = toIndex - fromIndex;

    for (int i = rangeLength / 2; i >= 0; --i) {
 	   maxSiftDown(array, fromIndex, toIndex, i);
    }
 }

// main function to do heap sort
template <class type>
 __device__ void heapSort(type *array, int fromIndex, int toIndex) {
     if (toIndex - fromIndex < 2) {
         return;
     }

     // CLRS says 'BUILD-MAX-HEAP' is O(n).
     buildMaxHeap(array, fromIndex, toIndex);

     // And this is O(n log n).
     for (int i = toIndex - 1; i > fromIndex; --i) {
         int tmp = array[i];
         array[i] = array[fromIndex];
         array[fromIndex] = tmp;
         maxSiftDown(array, fromIndex, i, 0);
     }
 }*/

 template <class type>
  __device__ void heapify(type *arr, int n, int i, int ini)
 {
 	int largest = i;  // Initialize largest as root
 	i -= ini;
 	int l = 2*i + 1 + ini;  // left = 2*i + 1
 	int r = 2*i + 2 + ini;  // right = 2*i + 2
 	i += ini;

 	// If left child is larger than root
 	if (l < n && arr[l] > arr[largest]){
 		largest = l;
 	}
 	// If right child is larger than largest so far
 	if (r < n && arr[r] > arr[largest]){
 		largest = r;
 	}
 	// If largest is not root
 	if (largest != i){
 		swapD(arr[i], arr[largest]);

 		// Recursively heapify the affected sub-tree
 		heapify(arr, n, largest, ini);
 	}
 }

 // main function to do heap sort
 template <class type>
  __device__ void heapSort(type *arr, int ini, int fin, int n)
 {
 	// Build heap (rearrange array)
 	for (int i = ((fin+1-ini)/ 2) - 1+ini; i >= ini; i--){
 		heapify(arr, fin+1, i, ini);
 	}
 	//printArray(arr, ini, n);

 	// One by one extract an element from heap
 	for (int i=fin; i>=ini; i--){
 		// Move current root to en
 		swapD(arr[ini], arr[i]);

 		// call max heapify on the reduced heap
 		heapify(arr, i, ini, ini);
 		//printArray(arr, ini, n);
 	}
 }


 int findArr(float input[], int size, int key){
          for(int i = 0; i < size; i++)
            {
               if(input[i] == key)
                  return 2;

            }

return 0;

}

__device__ void getMinMax(float input[], int beginPtr, int endPtr, float *ret){
          float min = input[beginPtr];
          float max = 0;
        // int *ret = new int[2];
          for(int i = beginPtr; i < endPtr; i++){
              if(min > input[i])
                  min = input[i];
              if (max < input[i])
                  max = input[i];
            }

     ret[0] = min;
     ret[1] = max;
//return ret;

}

__device__ void getSplitters (float input[], float splitters[], int sample[], int beginPtr, int endPtr){
           __shared__ float mySamples[SAMPLED];
            float *ret = new float[2];
            for(int i = 0; i < SAMPLED; i++)
	   mySamples[i] = input[beginPtr+sample[i]];

	 insertionSort(mySamples, 0, SAMPLED);
       int splitterIndex = blockIdx.x*(BUCKETS+1)+1;
       int splittersSize=0;
	 for(int i = (SAMPLED)/(BUCKETS);splittersSize < BUCKETS-1; i +=SAMPLED/(BUCKETS)){
            splitters[splitterIndex] = mySamples[i];
            splitterIndex++;
            splittersSize++;
             }
          getMinMax(input, beginPtr, endPtr, ret);
           splitters[blockIdx.x*(BUCKETS+1)] = ret[0]-2;//to accodmodate the smallest
           splitters[blockIdx.x*(BUCKETS+1)+BUCKETS] = ret[1];

      delete [] ret;
}

__device__ void getBuckets2(float input[], float splitters[], int beginPtr, int endPtr, int bucketsSize[], float myInput[]){
      int id = threadIdx.x;
      int sizeOffset = blockIdx.x*BUCKETS+threadIdx.x;
      int bucketSizeOff = sizeOffset+1;
      float myBucket[maxElements];
      int indexSum=0;
      bucketsSize[bucketSizeOff] = 0;

     for(int i = 0; i < maxElements; i++){
         if(myInput[i] > splitters[id] && myInput[i] <= splitters[id+1]){
         myBucket[bucketsSize[bucketSizeOff]] = myInput[i];
         bucketsSize[bucketSizeOff]++;

}


     }

   __syncthreads();

         //prefix sum for bucket sizes of current array
         for(int j = 0; j < threadIdx.x; j++)
            indexSum += bucketsSize[blockIdx.x*BUCKETS+j+1];

         //writing back current buckt back to the input memory
	 for(int i = 0; i < bucketsSize[bucketSizeOff]; i++)
             input[indexSum+beginPtr+i] = myBucket[i];


}



__device__ void getBuckets(float input[], float splitters[], int beginPtr, int endPtr, int bucketsSize[]){
      int id = threadIdx.x;
      int sizeOffset = blockIdx.x*BUCKETS+threadIdx.x;
      int bucketSizeOff = sizeOffset+1;
      float myBucket[maxElements];
      int indexSum=0;
      bucketsSize[bucketSizeOff] = 0;

     for(int i = 0; i < maxElements; i++){
         if(input[beginPtr+i] > splitters[id] && input[beginPtr+i] <= splitters[id+1]){
         myBucket[bucketsSize[bucketSizeOff]] = input[beginPtr+i];
         bucketsSize[bucketSizeOff]++;

}


     }

   __syncthreads();

         //prefix sum for bucket sizes of current array
         for(int j = 0; j < threadIdx.x; j++)
            indexSum += bucketsSize[blockIdx.x*BUCKETS+j+1];

         //writing back current buckt back to the input memory
	 for(int i = 0; i < bucketsSize[bucketSizeOff]; i++)
             input[indexSum+beginPtr+i] = myBucket[i];


}
__device__ void bucketer(int input[], int bucketsSize[], int sample[], int beginPtr, int endPtr, int output[]){
          int id = blockIdx.x;
          const int toBeSampled = SAMPLED;
         const  int buckets = BUCKETS;

        __shared__ int splitters[buckets-1];


        //converting samples into unsorted-unselected-splitters

    for(int i = 0; i < toBeSampled; i ++)
        sample[i] = input[beginPtr+sample[i]];
           insertionSort(sample, 0, toBeSampled);

         //taking splitters out
          int splittersSize=0;
	 for(int i = (toBeSampled)/(buckets);splittersSize < buckets-1; i +=toBeSampled/(buckets)){
             splitters[splittersSize] = sample[i];
            splittersSize++;
             }


          int sumBsize=0;
          int sIndex = 0;
          for(int i = id*BUCKETS; i < (id*BUCKETS+BUCKETS); i++){
              bucketsSize[i] = 0;
              for(int j = 0; j <maxElements ; j++){
              //for bucket 0
               if(sIndex == 0){
                if( input[beginPtr+j] <= splitters[0]){
		   output[beginPtr+sumBsize+bucketsSize[i]]=input[beginPtr+j];
                   bucketsSize[i]++;
                   }
                    }
              //for last bucket
               else if(sIndex == buckets-1){
                    if( input[beginPtr+j] > splitters[splittersSize-1]){

		   output[beginPtr+sumBsize+bucketsSize[i]] = input[beginPtr+j];
                   bucketsSize[i]++;
                       }
                  }
               else{
                    if( input[beginPtr+j] > splitters[sIndex-1] && input[beginPtr+j] <= splitters[sIndex]) {
		   output[beginPtr+sumBsize+bucketsSize[i]] = input[beginPtr+j];
                   bucketsSize[i]++;
                }

                }

	         }
                sumBsize += bucketsSize[i];
                sIndex++;
	      }
}


__global__ void splitterKer(float *data, float *splitters, int *mySample){
          if(blockIdx.x < numOfArrays){
             int id = blockIdx.x;
             int arrBegin = id*maxElements;
	     int arrEnd = arrBegin + maxElements;

	     __shared__ int sampleSh[SAMPLED];

	     for(int i = 0; i < SAMPLED; i++)
	        sampleSh[i] = mySample[i];

	     getSplitters(data, splitters, sampleSh, arrBegin, arrEnd);

          }
		  data[0] = 9999;
     }


__global__ void bucketEM2(float *data, int *bucketSizes, float *splittersGlob){
    if(blockIdx.x < numOfArrays){
        bucketSizes[0] = 0;
        int bid = blockIdx.x;
        int tid = threadIdx.x;
         int leftOvers = maxElements%BUCKETS;
         int jmpFac = maxElements/BUCKETS;
        int gArrayStart = bid*maxElements+tid*jmpFac;
        int gArrayEnd = (tid==(BUCKETS-1))?(gArrayStart + jmpFac+leftOvers):(gArrayStart + jmpFac);
        int lArrayStart = tid*jmpFac;
        __shared__ float myInput [maxElements];

        int arrBegin = bid*maxElements;
        int arrEnd = arrBegin + maxElements;
        int splitterIndexSt = blockIdx.x*(BUCKETS+1);
        int splitterIndexEd = splitterIndexSt + BUCKETS+1;
        __shared__ float splitters[BUCKETS+1];
//copy my array in shared memory in parallel
           for(int i=lArrayStart,j=gArrayStart;j<gArrayEnd;i++,j++){
                 myInput[i] = data[j];

        }
      __syncthreads();
        int j = 0;
        for(int i = splitterIndexSt; i < splitterIndexEd; i++){
           splitters[j] = splittersGlob[i];
           j++;
}

	getBuckets2(data, splitters, arrBegin, arrEnd, bucketSizes, myInput);

	}
}



__global__ void sortEM2(float *buckets, int *bucketSizes){
       if(blockIdx.x < numOfArrays && threadIdx.x < BUCKETS){
        int bid = blockIdx.x;
        int tid = threadIdx.x;
        int leftOvers = maxElements%BUCKETS;
        int jmpFac = maxElements/BUCKETS;
        int gArrayStart = bid*maxElements+tid*jmpFac;
         int gArrayEnd = (tid==(BUCKETS-1))?(gArrayStart + jmpFac+leftOvers):(gArrayStart + jmpFac);
        int lArrayStart = tid*jmpFac;

        __shared__ float myArray [maxElements];
        int indexSum = 0;


          for(int i=lArrayStart,j=gArrayStart;j<gArrayEnd;i++,j++){
                 myArray[i] = buckets[j];

        }
        __syncthreads();
          for(int j = 0; j < threadIdx.x; j++)
            indexSum += bucketSizes[blockIdx.x*BUCKETS+j+1];


		//   insertionSort(myArray, indexSum,indexSum+ bucketSizes[blockIdx.x*BUCKETS+threadIdx.x+1]);
		//heapSort(myArray, indexSum, indexSum + bucketSizes[blockIdx.x*BUCKETS+threadIdx.x+1]);
		heapSort(myArray, indexSum, indexSum + bucketSizes[blockIdx.x*BUCKETS+threadIdx.x+1], maxElements);
          __syncthreads();


           for(int i=lArrayStart,j=gArrayStart;j<gArrayEnd;i++,j++){
                 buckets[j] = myArray[i];
        }
     __syncthreads();
}


}

__global__ void sortEM(int *buckets, int *prefixSum){

      if(blockIdx.x < numOfArrays && threadIdx.x < BUCKETS){
        int bid = blockIdx.x;
        int tid = threadIdx.x;

        int left =(tid)+bid*(BUCKETS);
        int right = (tid+1)+bid*(BUCKETS);

          insertionSort(buckets, prefixSum[left], prefixSum[right]);
	  }
}



int main ()
{

	const int range_from = 0;
	// const unsigned int range_to = 2147483647; //2^31 - 1
	const unsigned int range_to = 1024;
	random_device rand_dev;
	mt19937 generator(rand_dev());
	uniform_int_distribution<int> distr(range_from, range_to);
	size_t f,t;
	int *d_bucketSizes , *h_bucketSizes;

	float *d_data, *h_buckets, *d_splitters, *h_splitters;
	int numBlocks = ceil((float)(BUCKETS*numOfArrays+1)/(BLOCK_SIZE<<1));
	dim3 dimGrid(numBlocks, 1, 1);
	dim3 dimBlock(BLOCK_SIZE, 1, 1);
	float *h_data = new float[numOfArrays*maxElements];
	h_buckets = new float[numOfArrays*maxElements];
	h_bucketSizes = new int[BUCKETS*numOfArrays+1];
	h_splitters = new float[(BUCKETS+1)*sizeof(float)*numOfArrays];
	size_t size_heap, size_stack;
	int *h_sample = new int[SAMPLED];
	int *d_sample;
	//cudaSetDevice(0);
	cudaMemGetInfo(&f, &t);

	//setting stack size limit
	cudaDeviceSetLimit(cudaLimitStackSize,10240);
	cudaDeviceGetLimit(&size_heap, cudaLimitMallocHeapSize);
	cudaDeviceGetLimit(&size_stack, cudaLimitStackSize);

	//generating regular samples
	int max = maxElements;
	int  sam = SAMPLED;
	int stride = max/sam;
	int sampleVal = 0;
	for( int i = 0; i < SAMPLED; i++){
		h_sample[i] = sampleVal;
		sampleVal += stride;
	}


	// allocating device memory for data, sampled indices and bucket sizes
	cudaMalloc((void**) &d_sample, SAMPLED*sizeof(float));
	cudaMalloc((void**) &d_data, numOfArrays*maxElements*sizeof(float));
	cudaMalloc((void**) &d_bucketSizes, numOfArrays*sizeof(int)*BUCKETS+sizeof(int));
	cudaMalloc((void**) &d_splitters, (BUCKETS+1)*sizeof(float)*numOfArrays);
	srand(time(NULL));
	cudaMemGetInfo(&f,&t);

	//new data gens
	//cout<<"OJO"<<endl;
	for(int i = 0; i < numOfArrays; i++){
		for(int j = 0; j < maxElements; j++){
			h_data [j+i*maxElements] = distr(generator) ;
			//cout<<h_data [j+i*maxElements]<<",";
		}
		//cout<<endl;
	}

	//copy data and samples to GPU
	cudaMemcpy(d_data, h_data, numOfArrays*maxElements*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_sample, h_sample, SAMPLED*sizeof(float), cudaMemcpyHostToDevice);

	clock_t firstKrTime = clock();
	splitterKer<<<numOfArrays,1>>>(d_data, d_splitters, d_sample);
	cudaThreadSynchronize();
	firstKrTime = clock() - firstKrTime;

	cudaError_t errSync  = cudaGetLastError();
	cudaError_t errAsync = cudaDeviceSynchronize();
	if (errSync != cudaSuccess){
		printf("Sync kernel error: %s\n", cudaGetErrorString(errSync));
	}
	if (errAsync != cudaSuccess){
		printf("Async kernel error: %s\n", cudaGetErrorString(errAsync));
	}

	cudaMemcpy(h_splitters, d_splitters, (BUCKETS+1)*sizeof(float)*numOfArrays, cudaMemcpyDeviceToHost);

	clock_t secondKrTime = clock();
	//cout<<secondKrTime<<endl;
	bucketEM2<<<numOfArrays,BUCKETS>>>(d_data, d_bucketSizes, d_splitters);
	cudaThreadSynchronize();
	secondKrTime = clock()-secondKrTime;
	//cout<<secondKrTime<<endl;
	//cout<<"--------"<<endl;
	cudaMemGetInfo(&f,&t);

	//copying bucket sizes from first kernel back to cpu for prefix sum, to be replaced with prefix sum code
	cudaMemcpy(h_bucketSizes, d_bucketSizes, sizeof(int)*(BUCKETS*numOfArrays+1), cudaMemcpyDeviceToHost);
	//freeing the sample indices memory space and bucket sizes memory
	cudaFree(d_sample);
	cudaFree(d_splitters);

	clock_t fourKrTime = clock();
	sortEM2<<<numOfArrays, BUCKETS>>>(d_data, d_bucketSizes);

	cudaThreadSynchronize();

	fourKrTime = clock()-fourKrTime;

	cout<<(firstKrTime+secondKrTime+fourKrTime)/double(CLOCKS_PER_SEC)*1000<<endl;
	//copying the sorted data back
	cudaMemcpy(h_buckets, d_data, numOfArrays*maxElements*sizeof(float), cudaMemcpyDeviceToHost);

	// for(int i = 0; i < numOfArrays; i++){
	// 	for(int j = 0; j < maxElements; j++){
	// 		cout<<h_buckets[j+i*maxElements]<<"-";
	// 	}
	// 	cout<<endl;
	// }

	//freeing the space for prefixSum and sorted data
	cudaFree(d_data);
	cudaFree(d_bucketSizes);

	free(h_bucketSizes);
	free(h_buckets);
	free(h_data);
	free(h_sample);
	free(h_splitters);
	return 0;
}
