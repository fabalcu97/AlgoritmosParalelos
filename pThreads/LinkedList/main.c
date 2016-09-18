#include <time.h>
#include "LinkedList.h"

struct list_node_s* head_p = NULL;
pthread_mutex_t list_mutex;
pthread_rwlock_t* rwlock;

void* _Threads(void*);

int main(int argc, char const *argv[]) {

	srand(time(NULL));
	int n = atoi(argv[1]);
	long i = 0;

	clock_t start_t, end_t;
	double total_t;
	pthread_t* threads;
	threads = (pthread_t*) malloc(sizeof(pthread_t) * n);

	start_t = clock();

	for( i = 0; i < n; ++i){
		pthread_create(&threads[i], NULL, _Threads, (void*) i);
	}
	for( i = 0; i < n; ++i){
		pthread_join(threads[i], NULL);
	}

	end_t = clock();

	total_t = (double)(end_t - start_t) / CLOCKS_PER_SEC;
	printf("Total time: %f with %d threads.\n", total_t, n );

	return 0;
}


void* _Threads(void* rnk){
	int i = 0;

	//Read-Write lock
	/*
	for(i = 0; i <= 10000; ++i){
		pthread_rwlock_wrlock(&rwlock);
		Insert(rand() % 1000, &head_p);
		pthread_rwlock_unlock(&rwlock);
	}
	for(i = 0; i <= 80000; ++i){
		pthread_rwlock_rdlock(&rwlock);
		Member(rand() % 1000, head_p);
		pthread_rwlock_unlock(&rwlock);
	}
	for(i = 0; i <= 10000; ++i){
		pthread_rwlock_wrlock(&rwlock);
		Delete(rand() % 1000, &head_p);
		pthread_rwlock_unlock(&rwlock);
	}*/

	//Mutex per operation
	/*
	for(i = 0; i <= 10000; ++i){
		pthread_mutex_lock(&list_mutex);
		Insert(rand() % 1000, &head_p);
		pthread_mutex_unlock(&list_mutex);
	}
	for(i = 0; i <= 10000; ++i){
		pthread_mutex_lock(&list_mutex);
		Delete(rand() % 1000, &head_p);
		pthread_mutex_unlock(&list_mutex);
	}
	for(i = 0; i <= 80000; ++i){
		pthread_mutex_lock(&list_mutex);
		Member(rand() % 1000, head_p);
		pthread_mutex_unlock(&list_mutex);
	}*/

	//Mutex per node

	for(i = 0; i <= 10000; ++i){
		Mutex_Insert(rand() % 1000, &head_p);
	}
	for(i = 0; i <= 80000; ++i){
		Mutex_Member(rand() % 1000, head_p);
	}
	for(i = 0; i <= 10000; ++i){
		Mutex_Delete(rand() % 1000, &head_p);
	}
	return NULL;
}
