#include <iostream>
#include <mpi.h>

#define MAX 5
#define MASTER 0

using namespace std;

int main(int argc, char* argv[]) {

	int comm_sz, my_rank;

	srand(time(nullptr));

	int tmp[MAX],
		tmp1[MAX],
		result = 0;

	MPI_Init(&argc, &argv);

	MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

	if( my_rank != 0 ){
		MPI_Recv(&tmp, 1, MPI_INT, MASTER, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
		for (int i = 0; i < MAX; ++i){
			cout<<tmp[i]<<endl;
		}
		for (int i = 0; i < MAX; ++i) {
			MPI_Recv(&tmp1, 1, MPI_INT, MASTER, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
			for(int j = 0; j < MAX; ++j){
				result += tmp[j] * tmp1[j];
			}
		}
		MPI_Send(&result, 1, MPI_INT, MASTER, 0, MPI_COMM_WORLD);
	}
	else if( my_rank == 0 ){

		int R[MAX][MAX],
			A[MAX][MAX],
			B[MAX][MAX];

		for (int i = 0; i < MAX; ++i) {
			for (int j = 0; j < MAX; ++j) {
				A[i][j] = rand() % 10;
			}
		}
		for (int i = 0; i < MAX; ++i) {
			for (int j = 0; j < MAX; ++j) {
				B[i][j] = rand() % 10;
			}
		}

		for(int k = 0; k < MAX; ++k){
			MPI_Send(A[k], 0, MPI_INT, k, 0, MPI_COMM_WORLD);
			for (int i = 0; i < MAX; ++i) {
				for (int j = 0; j < MAX; ++j) {
					tmp[j] = B[j][i];
				}
				MPI_Send(tmp, 0, MPI_INT, i, 0, MPI_COMM_WORLD);
			}
		}
		int cnt = 1;
		for (int i = 0; i < MAX; ++i) {
			for (int j = 0; j < MAX; ++j){
				MPI_Recv(&R[i][j], 1, MPI_INT, cnt, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
				++cnt;
			}
		}

		cout<<endl<<endl;
		for(int i = 0; i < MAX; ++i){
			for(int k = 0; k < MAX; ++k){
				cout<<A[i][k]<<"|";
			}
			cout<<endl<<"-----------------------------"<<endl;
		}
		cout<<endl<<endl;

		for(int i = 0; i < MAX; ++i){
			for(int k = 0; k < MAX; ++k){
				cout<<B[i][k]<<"|";
			}
			cout<<endl<<"-----------------------------"<<endl;
		}
		cout<<endl<<endl;

		for(int i = 0; i < MAX; ++i){
			for(int k = 0; k < MAX; ++k){
				cout<<R[i][k]<<"|";
			}
			cout<<endl<<"-----------------------------"<<endl;
		}
	}

	MPI_Finalize();
	return 0;
}
