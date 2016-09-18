#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>

#define MOD 100000

void* pth_mat_vect(void*);

int	m,
	n,
	thread_count;

int*	A;
int*	x;
int*	y;


int main(int argc, char const *argv[]) {

	int	i = 0,
		j = 0;

	long thread = 0;

	clock_t start_t,
			end_t;

	srand(time(NULL));

	thread_count = atoi(argv[1]);	//Número de hilos
	n = atoi(argv[2]);		//Número de filas de la matriz
	m = atoi(argv[3]);		//Número de filas del vector, columnas de la matriz

	pthread_t* threads;

	threads = (pthread_t*) malloc( sizeof(pthread_t) * thread_count );
	y = (int*) malloc( n * sizeof(int) );
	x = (int*) malloc( m * sizeof(int) );

	A = malloc(sizeof(int) * m*n);

	for(i = 0; i < m*n; ++i){
		A[i] = rand() % MOD;
	}

	for (j = 0; j < m; ++j) {
		x[j] = rand() % MOD;
	}
	start_t = clock();

	for( thread = 0; thread < thread_count; ++thread){
		pthread_create(&threads[thread], NULL, pth_mat_vect, (void*) thread);
	}
	for( thread = 0; thread < thread_count; ++thread){
		pthread_join(threads[thread], NULL);
	}
	end_t = clock();

	printf("For %d cores Time elapsed: %f\n",thread_count, (double) (end_t - start_t) / CLOCKS_PER_SEC );

//Impresión
/*
	for (i = 0; i < n; ++i) {
		for (j = 0; j < m; j++){
			printf("%d|", A[i*m+j]);
		}
		printf("\n");
	}
	printf("\n");
	printf("\n");
	for (j = 0; j < m; ++j) {
		printf("%d-", x[j]);
	}
	printf("\n");
	printf("\n");
	for (j = 0; j < m; ++j) {
		printf("%d\n", y[j]);
	}
	printf("\n");
*/

	free(A);
	free(x);
	free(y);
	free(threads);

	return 0;
}

void* pth_mat_vect(void* rank){


	long my_rank = (long) rank;
	int i,
		j,
		local_m = n/thread_count,
		my_first_row = my_rank * local_m,
		my_last_row = ( my_rank + 1 ) * local_m - 1;
	for (i = my_first_row; i <= my_last_row; ++i) {
		y[i] = 0.0;
		for (j = 0; j < m; j++){
			y[i] += A[i*m+j] * x[j];
		}
	}
	return NULL;
} /* Pth mat vect */
