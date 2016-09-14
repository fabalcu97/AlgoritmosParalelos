#include <iostream>
#include <pthread.h>

using namespace std;

void* pi_sum_bw(void*);

int n = 0,
	thread_count = 0,
	my_n = 0,
	flag = 0;
double sum = 0;

int main(int argc, const char *argv[]) {
	long thread;
	pthread_t* threads;

	thread_count = atoi(argv[1]);	//Cantidad de hilos
	n = atoi(argv[2]);				//Argumento de precision
	my_n = n / thread_count;
	cout<<"my_n: "<<my_n<<endl;

	threads = (pthread_t*) malloc( thread_count * sizeof(pthread_t) );

	for( thread = 0; thread < thread_count; ++thread){
		pthread_create( &threads[thread], NULL, pi_sum_bw, (void*) thread );
	}


	for( thread = 0; thread < thread_count; ++thread){
		pthread_join( threads[thread], NULL );
	}

	sum *= 4.0;
	cout<<"The value of PI with "<<n<<" precision is: "<<sum<<endl;

	free(threads);

	return 0;
}

void* pi_sum_bw(void* rank){
	long my_rank = (long) rank;

	long long	my_first_i = my_n * my_rank,
				my_last_i = my_first_i + my_n;

	double 	factor = my_first_i % 2 ? 1.0 : -1.0,
			my_sum = 0.0;

	for( int i = my_first_i; i < my_last_i; ++i, factor = -factor){
		my_sum += factor/( (2 * i) + 1);
	}
	cout<<"Process: "<<my_rank<<"---My_sum: "<<my_sum<<endl;
	while( flag != my_rank );
	sum += my_sum;
	flag = (flag + 1) % thread_count;

	return NULL;
}
