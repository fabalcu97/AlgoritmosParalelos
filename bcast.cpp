#include <iostream>
#include <mpi.h>

using namespace std;

int Bcast(int in_val, int my_rank, int p, MPI_Comm comm);

int main() {

	int comm_sz,
		my_rank,
		result,
		BC_val;

	double 	TStart,
			TEnd,
			TElapsed;

	MPI_Init(nullptr, nullptr);
	MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

	if (my_rank == 0) {
		BC_val = 10;	//Comunicar numero 10
	}

	MPI_Barrier(MPI_COMM_WORLD);
	TStart = MPI_Wtime();

	result = Bcast(BC_val, my_rank, comm_sz, MPI_COMM_WORLD);
	// MPI_Bcast(&BC_val, 0, MPI_INT, 0, MPI_COMM_WORLD);

	MPI_Barrier(MPI_COMM_WORLD);
	TEnd = MPI_Wtime();
	TElapsed = TEnd- TStart;

	cout<<"Proceso "<<my_rank<<" tiene el valor "<<result<<" en el tiempo "<<TElapsed<<endl;
	// cout<<"Proceso "<<my_rank<<" tiene el valor "<<BC_val<<" en el tiempo "<<TElapsed<<endl;

	MPI_Finalize();
	return 0;
}

/*int Bcast(int input, int my_rank, int total, MPI_Comm comm) {

	int step = 0,
		nxt;

	for (; step < (log(total)); step++){
		nxt = pow(2,step);
		if ((my_rank < nxt) && (nxt + my_rank < total)){
			MPI_Send(&input, 1, MPI_DOUBLE, (nxt + my_rank), 0, MPI_COMM_WORLD);
		}
		else if (my_rank < (nxt << 1)){
			MPI_Recv(&input, 1, MPI_DOUBLE, (my_rank - nxt), 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
		}
	}
	return input;
}*/

int Bcast(int input, int my_rank, int total, MPI_Comm comm) {

	unsigned paso = 1;

	int	NodoANivel,
		participate = paso << 1;

	for(; paso < total; paso <<= 1, participate <<= 1){
		if (my_rank < participate) {

			NodoANivel = my_rank ^ paso;
			if ( (NodoANivel < total) && (my_rank < NodoANivel) ) {
				MPI_Send(&input, 1, MPI_INT, NodoANivel, 0, comm);
			}
			else if (NodoANivel <= my_rank){
				MPI_Recv(&input, 1, MPI_INT, NodoANivel, 0, comm, MPI_STATUS_IGNORE);
			}
		}

	}
	return input;

}
