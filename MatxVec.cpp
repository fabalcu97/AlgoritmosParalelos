#include <iostream>
#include <mpi.h>

using namespace std;

int main(int argc, char* argv[]) {

	int m,
		n,
		i,
		j,
		local_m,
		local_n;

	double 	local_start,
			local_finish,
			local_elapsed,
			elapsed;

	MPI_Comm comm;

	m = atoi(argv[1]);
	n = atoi(argv[1]);

	srand(time(NULL));

	int v[n];

	int* A = (int*) malloc(sizeof(int) * m*n);

	int my_rank;
	int comm_sz;

	MPI_Init(&argc, &argv);
	comm = MPI_COMM_WORLD;
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
	MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);

	local_m = m/comm_sz;
	local_n = n/comm_sz;

	if( my_rank == 0 ){

		for(i = 0; i < m*n; ++i){
			A[i]=(rand() % 20);
		}
		for(i = 0; i < n; ++i){
			v[i] = (rand() % 20);
		}
	}

	MPI_Barrier(comm);
	local_start=MPI_Wtime();

	int* local_A = (int*) malloc(sizeof(int) * local_m*n);
	int* local_x = (int*) malloc(sizeof(int) * local_n);
	int* local_y = (int*) malloc(sizeof(int) * local_m);
	int* rpta = (int*) malloc(sizeof(int) * m);

	MPI_Scatter(A, local_m*n, MPI_INT, local_A, local_m*n, MPI_INT, 0, comm);
	MPI_Scatter(v, local_n, MPI_INT, local_x, local_n, MPI_INT, 0, comm);

	int* x = (int*) malloc(n*sizeof(int));

	MPI_Allgather(local_x, local_n, MPI_INT, x, local_n, MPI_INT, comm);

	for(i = 0; i < local_m; ++i){
		local_y[i] = 0;
		for(j = 0; j < n; ++j){
			local_y[i] += local_A[i*n+j]*x[j];
		}
	}

	free(x);

	MPI_Gather(local_y, local_m, MPI_INT, rpta, local_m, MPI_INT, 0, MPI_COMM_WORLD);

	local_finish = MPI_Wtime();
	local_elapsed = local_finish-local_start;

	MPI_Reduce(&local_elapsed, &elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, comm);

	if( my_rank == 0 ){
		/*cout<<"A: ";
		for(j = 0; j < n; ++j){
			cout<<A[j]<<"|";
		}
		cout<<endl<<"B: ";
		for(j = 0; j < n; ++j){
			cout<<v[j]<<"|";
		}
		cout<<endl<<"R: ";
		for(j = 0; j < n; ++j){
			cout<<rpta[j]<<"|";
		}
		cout<<endl;*/
		printf("Elapsed time = %f seconds for %d elements\n", elapsed, m*n);
	}

	MPI_Finalize();

	return 0;
}
