#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

pthread_mutex_t head_p_mutex;

struct list_node_s {
	int data;
	struct list_node_s* next;
	pthread_mutex_t mutex;

};

int Member( int value, struct list_node_s* head_pp){
	struct list_node_s* curr_p = head_pp;

	while ( curr_p != NULL && curr_p->data < value) {
		curr_p = curr_p->next;
	}

	if ( curr_p == NULL || curr_p->data > value) {
		return 0;
	}
	return 1;
};


int Mutex_Member( int value, struct list_node_s* head_pp){
	struct list_node_s* temp_p;

	pthread_mutex_lock(&head_p_mutex);
	temp_p = head_pp;
	while ( temp_p != NULL && temp_p->data < value) {
		if( temp_p->next != NULL ){
			pthread_mutex_lock(&(temp_p->next->mutex));
		}
		if (temp_p == head_pp) {
			pthread_mutex_unlock(&head_p_mutex);
		}
		pthread_mutex_unlock(&(temp_p->mutex));
		temp_p = temp_p->next;
	}
	if ( temp_p == NULL || temp_p->data > value ) {
		if( temp_p == head_pp ){
			pthread_mutex_unlock(&head_p_mutex);
		}
		if(temp_p != NULL){
			pthread_mutex_unlock(&(temp_p->mutex));
		}
		return 0;
	}
	else{
		if (temp_p == head_pp) {
			pthread_mutex_unlock(&head_p_mutex);
		}
		pthread_mutex_unlock(&(temp_p->mutex));
		return 1;
	}
};


void Print(struct list_node_s** head_pp ){

	struct list_node_s* curr_p = *head_pp;

	while ( curr_p != NULL ) {
		printf("%d-", curr_p->data);
		curr_p = curr_p->next;
	}
	printf("\n");
};

int Insert(int value, struct list_node_s** head_pp ){

	struct list_node_s* curr_p = *head_pp;
	struct list_node_s* pred_p = NULL;
	struct list_node_s* temp_p;

	while ( curr_p != NULL && curr_p->data < value ) {
		pred_p = curr_p;
		curr_p = curr_p->next;
	}

	if ( curr_p == NULL || curr_p->data > value) {
		temp_p = (struct list_node_s*) malloc(sizeof(struct list_node_s));
		temp_p->data = value;
		temp_p->next = curr_p;

		// printf("Inserto %d\n", value);

		if( pred_p == NULL ){
			*head_pp = temp_p;
		}
		else{
			pred_p->next = temp_p;
		}
		return 1;
	}
	else{
		return 0;
	}

};

int Mutex_Insert(int value, struct list_node_s** head_pp ){

	struct list_node_s* curr_p = *head_pp;
	struct list_node_s* pred_p = NULL;
	struct list_node_s* temp_p;

	while ( curr_p != NULL && curr_p->data < value ) {
		pred_p = curr_p;
		curr_p = curr_p->next;
	}

	/*pthread_mutex_lock(&head_p_mutex);
	while ( curr_p != NULL && curr_p->data < value) {
		if( curr_p->next != NULL ){
			pthread_mutex_lock(&(curr_p->next->mutex));
		}
		if (curr_p == *head_pp) {
			pthread_mutex_unlock(&head_p_mutex);
		}
		pthread_mutex_unlock(&(curr_p->mutex));

		curr_p = curr_p->next;
	}*/

	if ( curr_p == NULL || curr_p->data > value) {
		temp_p = (struct list_node_s*) malloc(sizeof(struct list_node_s));
		temp_p->data = value;
		temp_p->next = curr_p;

		if( pred_p == NULL ){
			pthread_mutex_lock(&head_p_mutex);
			*head_pp = temp_p;
			pthread_mutex_unlock(&head_p_mutex);
		}
		else{
			pthread_mutex_lock(&(temp_p->mutex));
			pred_p->next = temp_p;
			pthread_mutex_unlock(&(temp_p->mutex));
		}
		return 1;
	}
	else{
		return 0;
	}

};

int Delete(int value, struct list_node_s** head_pp){

	struct list_node_s* curr_p = *head_pp;
	struct list_node_s* pred_p = NULL;

	while ( curr_p != NULL && curr_p->data < value ) {
		pred_p = curr_p;
		curr_p = curr_p->next;
	}

	/*
	pthread_mutex_lock(&head_p_mutex);
	while ( curr_p != NULL && curr_p->data < value) {
		if( curr_p->next != NULL ){
			pthread_mutex_lock(&(curr_p->next->mutex));
		}
		if (curr_p == *head_pp) {
			pthread_mutex_unlock(&head_p_mutex);
		}
		pthread_mutex_unlock(&(curr_p->mutex));

		curr_p = curr_p->next;
	}
	*/

	if( curr_p != NULL && curr_p->data < value ){
		if(pred_p == NULL){
			*head_pp = curr_p->next;
			free(curr_p);
		}
		else{
			pred_p->next = curr_p->next;
			free(curr_p);
		}
		return 1;
	}
	else{
		return 0;
	}
};

int Mutex_Delete(int value, struct list_node_s** head_pp){

	struct list_node_s* curr_p = *head_pp;
	struct list_node_s* pred_p = NULL;

	while ( curr_p != NULL && curr_p->data < value ) {
		pred_p = curr_p;
		curr_p = curr_p->next;
	}

	if( curr_p != NULL && curr_p->data < value ){
		if(pred_p == NULL){
			pthread_mutex_lock(&head_p_mutex);
			*head_pp = curr_p->next;
			free(curr_p);
			pthread_mutex_unlock(&head_p_mutex);
		}
		else{
			pthread_mutex_lock(&(curr_p->mutex));
			pred_p->next = curr_p->next;
			free(curr_p);
			pthread_mutex_unlock(&(curr_p->mutex));
		}
		return 1;
	}
	else{
		return 0;
	}
};
