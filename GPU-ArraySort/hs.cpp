#include <iostream>

using namespace std;

/* A utility function to print array of size n */
void printArray(int arr[], int ini, int n)
{
	for (int i=ini; i<n; ++i){
		cout << arr[i] << " ";
	}
	cout << "\n";
}
// To heapify a subtree rooted with node i which is
// an index in arr[]. n is size of heap
void heapify(int arr[], int n, int i, int ini)
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
		swap(arr[i], arr[largest]);

		// Recursively heapify the affected sub-tree
		heapify(arr, n, largest, ini);
	}
}

// main function to do heap sort
void heapSort(int arr[], int ini, int fin, int n)
{
	// Build heap (rearrange array)
	for (int i = ((fin+1-ini)/ 2) - 1+ini; i >= ini; i--){
		heapify(arr, fin+1, i, ini);
	}
	printArray(arr, ini, n);

	// One by one extract an element from heap
	for (int i=fin; i>=ini; i--){
		// Move current root to en
		swap(arr[ini], arr[i]);

		// call max heapify on the reduced heap
		heapify(arr, i, ini, ini);
		printArray(arr, ini, n);
	}
}


// Driver program
int main()
{
	int arr[] = {21, 23, 34, 45, 56, 1, 2, 3, 4, 2, 58, 20, 13};
	int n = sizeof(arr)/sizeof(arr[0]);

	heapSort(arr, 3, 6, n);

	cout << "Sorted array is \n";
	printArray(arr, 3, n);
}
