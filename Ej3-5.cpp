#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mpi.h>

void Mat_vect_mult(int local_A[], int local_x[], int local_y[], int local_m, int n, int local_n, MPI_Comm comm, int rank);

int main(int argc, char* argv[]) {

	int m, n, n_local, i,j,local_m,local_n;
	double local_start, local_finish, local_elapsed, elapsed;
	MPI_Comm comm;

	m=atoi(argv[1]);
	n=atoi(argv[1]);
	srand(time(NULL));
	printf("Vivo\n");
	int A[m*n], v[n], result[n], displs[n], counts[n];
	int rank;
	int size;

        MPI_Init(&argc, &argv);
	comm = MPI_COMM_WORLD;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	int conts[size];

	local_m=m/size;
	local_n=n/size;


	MPI_Barrier(comm);
	local_start=MPI_Wtime();
	int *local_A = (int *)malloc(sizeof(int) * local_m*n);
	int *envio = (int *)malloc(sizeof(int) * local_m*n);
	int *local_x = (int *)malloc(sizeof(int) * local_n);
	int *local_y = (int *)malloc(sizeof(int) * m);
	int *res = (int *)malloc(sizeof(int) * m);

	if(rank==0){

		for(i=0;i<m*n;++i){
			A[i]=(rand() %10);
			printf("%d, ",A[i]);
		}

		for(i=0; i<n; ++i){
			v[i]=(rand() %10);
		}

		for(j=0; j<local_m*n; ++j)
			local_A[j]=A[j*n];

		for(i=1; i<size; ++i){

			for(j=0; j<local_m*n; ++j)
				envio[j]=A[i*local_m+j*n];
			MPI_Send(envio, local_m*n, MPI_INT, i, 0, comm);
		}
	}
	else{

		MPI_Recv(local_A, local_m*n, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	}

	MPI_Scatter(v, local_n, MPI_INT, local_x, local_n, MPI_INT, 0, comm);

	for(i=0; i<local_m; ++i){


		for(j=0; j<n; ++j){
			local_y[i*n+j]=0;
			local_y[i*n+j]+=local_A[i*n+j]*local_x[i];
			printf("Proceso %d, opero %d x %d\n", rank,local_A[i*n+j],local_x[i]);
		}
	}

	MPI_Reduce(local_y, res, m , MPI_FLOAT, MPI_SUM, 0, MPI_COMM_WORLD);

	for(i=0; i<local_m*n; ++i)
		printf("Proceso %d, tengo %d\n", rank,local_A[i]);

	if(rank==0){

		for(i=0; i<m; ++i){
			printf("%d, ",res[i]);
		}
		//printf("Elapsed time = %e seconds\n", elapsed);
	}
	MPI_Finalize();

	return 0;
}
