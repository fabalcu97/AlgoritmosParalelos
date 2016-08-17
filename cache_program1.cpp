#include <iostream>
#include <random>
#include <time.h>

using namespace std;
#define MAX 510

int main() {

    double A[MAX][MAX], x[MAX], y[MAX];
    srand(time(NULL));

    for( int i = 0; i < MAX; i++){
        x[i] = rand() % 50;
        y[i] = 0;

        for ( int j = 0; j < MAX; j++){
            A[i][j] = rand() % 50;
        }
    }

    clock_t tStart = clock();

    for( int i = 0; i < MAX; i++){
        for ( int j = 0; j < MAX; j++){
            y[i] += A[i][j] * x[j];
        }

    }

    printf("Time 1: %.6fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
/////////////////////
    tStart = clock();

    for ( int j = 0; j < MAX; j++){
        for( int i = 0; i < MAX; i++){
            y[i] += A[i][j] * x[j];
        }

    }

    printf("Time 2: %.6fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);

    return 0;
}
