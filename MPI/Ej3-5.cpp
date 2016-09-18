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

	MPI_Comm comm;

	m=atoi(argv[1]);
	n=atoi(argv[1]);
	srand(time(NULL));

	int A[m*n], v[n];
	int my_rank;
	int comm_sz;

        MPI_Init(&argc, &argv);
	comm = MPI_COMM_WORLD;
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
	MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);

	local_m = m / comm_sz;
	local_n = n / comm_sz;


	int *local_A = (int *)malloc(sizeof(int) * local_m*n);
	int *send = (int *)malloc(sizeof(int) * local_m*n);
	int *local_x = (int *)malloc(sizeof(int) * local_n);
	int *local_y = (int *)malloc(sizeof(int) * m);
	int *res = (int *)malloc(sizeof(int) * m);

	if( my_rank == 0 ){

		cout<<"A: ";
		for( i = 0; i < m*n; ++i ){
			A[i] = rand() % 20;
			cout<<A[i]<<"-";
		}
		cout<<endl<<"V: ";
		for( i = 0; i < n; ++i ){
			v[i] = rand() % 20;
			cout<<v[i]<<"-";
		}
		cout<<endl;
		for( j = 0; j < local_m*n; ++j ){
			local_A[j] = A[j*n];
		}
		for( i = 1; i < comm_sz; ++i ){
			for( j = 0; j < local_m*n; ++j ){
				send[j] = A[i*local_m+j*n];
			}
			MPI_Send(send, local_m*n, MPI_INT, i, 0, comm);
		}
	}
	else{

		MPI_Recv(local_A, local_m*n, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	}

	MPI_Scatter(v, local_n, MPI_INT, local_x, local_n, MPI_INT, 0, comm);

	for( i = 0; i < local_m; ++i ){
		for( j = 0; j < n; ++j ){
			local_y[i*n+j] = 0;
			local_y[i*n+j] += local_A[i*n+j] * local_x[i];
		}
	}

	MPI_Reduce(local_y, res, m , MPI_FLOAT, MPI_SUM, 0, MPI_COMM_WORLD);

	if( my_rank == 0 ){

		for( i = 0; i < m; ++i ){
			cout<<res[i]<<"-";
		}
		cout<<endl;
	}
	MPI_Finalize();

	return 0;
}
