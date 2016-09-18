# include <cstdlib>
# include <ctime>
# include <iomanip>
# include <iostream>
# include <mpi.h>

#define MASTER 0
#define CHILD 1

using namespace std;

int main (){

	int my_rank,
		comm_sz,
		message,
		count = 1;

	bool flag = true;

	MPI_Init(nullptr, nullptr);
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
	MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);

	srand(time(NULL));

	if( my_rank != 0 ){
		while (count <= 50) {
			if(flag){
				message = rand() % 10;
				MPI_Send(&message, 1, MPI_INT, MASTER, 0, MPI_COMM_WORLD);
				printf("Proc %d Sending %d on iteration number: %d\n", my_rank, message, count);
			}
			else{
				MPI_Recv(&message, 1, MPI_INT, MASTER, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
				printf("Proc %d Receiving %d on iteration number: %d\n", my_rank, message, count);
			}
			flag = !flag;
			count += 1;
		}
	}
	if ( my_rank == 0 ) {
		while (count <= 50) {
			if(flag){
				MPI_Recv(&message, 1, MPI_INT, CHILD, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
				printf("Proc %d Receiving %d on iteration number: %d\n", my_rank, message, count);
			}
			else{
				MPI_Send(&message, 1, MPI_INT, CHILD, 0, MPI_COMM_WORLD);
				printf("Proc %d Sending %d on iteration number: %d\n", my_rank, message, count);
			}
			flag = !flag;
			count += 1;
		}
	}
	MPI_Finalize();
	return 0;

}