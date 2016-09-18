/* File:     pth_pi_busy.c
 * Purpose:  Estimate pi using the Maclaurin series for arctan(x):
 *
 *              arctan(x) = Sum_n=0 ^infty (-1)^n x^(2n+1)/(2n+1), |x| <= 1
 *
 *           Since arctan(1) = pi/4, we can compute
 *
 *              pi = 4*[1 - 1/3 + 1/5 - 1/7 + 1/9 - . . . ]
 *
 * Compile:  gcc -g -Wall -o pth_pi_busy pth_pi_busy.c -lm -lpthread
 * Run:      ./pth_pi_busy <number of threads> <n>
 *           n is the number of terms of the Maclaurin series to use
 *           n should be evenly divisible by the number of threads
 * Input:    none
 * Output:   Estimate of pi as computed by multiple threads, estimate
 *           as computed by one thread, and 4 arctan(1).
 *           If the macro TIMING is defined, this version also prints
 *           the elapsed time required for the multi-threaded and
 *           single-threaded calculations.
 *
 * Notes:
 *    1.  The radius of convergence for the series is only 1.  So the
 *        series converges quite slowly.
 *    2.  This version uses busy-waiting to limit access to the critical
 *        section.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <pthread.h>
#include <timer.h>

const int MAX_THREADS = 1024;

long thread_count;
long long n;
int flag;
// volatile int flag;
double sum;
// volatile double sum;

#ifdef DEBUG
double *vals;
#endif

void* Thread_sum(void* rank);

/* Only executed by main thread */
void Get_args(int argc, char* argv[]);
void Usage(char* prog_name);
double Serial_pi(long long n);

int main(int argc, char* argv[]) {
   long       thread;  /* Use long in case of a 64-bit system */
   pthread_t* thread_handles;
   double start, finish;
#  ifdef DEBUG
   int i;
#  endif

   /* Get number of threads and number of terms from command line */
   Get_args(argc, argv);

   thread_handles = malloc (thread_count*sizeof(pthread_t));
#  ifdef DEBUG
   vals = malloc(n*sizeof(double));
   for (i = 0; i < n; i++)
      vals[i] = 0.0;
#  endif

   GET_TIME(start);
   sum = 0.0;
   flag = 0;
   for (thread = 0; thread < thread_count; thread++)
      pthread_create(&thread_handles[thread], NULL,
          Thread_sum, (void*)thread);

   for (thread = 0; thread < thread_count; thread++)
      pthread_join(thread_handles[thread], NULL);
   sum = 4.0*sum;
   GET_TIME(finish);

   printf("With n = %lld terms,\n", n);
   printf("   Multi-threaded estimate of pi  = %.15f\n", sum);
#  ifdef TIMING
   printf("   Elapsed time = %e seconds\n", finish-start);
#  endif
#  ifdef DEBUG
   printf("Vals added in:\n   ");
   for (i = 0; i < n; i++)
      printf("%6.3e ", vals[i]);
   printf("\n");
#  endif

   GET_TIME(start);
   sum = Serial_pi(n);
   GET_TIME(finish);
   printf("   Single-threaded estimate of pi = %.15f\n", sum);
#  ifdef TIMING
   printf("   Elapsed time = %e seconds\n", finish-start);
#  endif
   printf("   Math library estimate of pi    = %.15f\n",
       4.0*atan(1.0));
#  ifdef DEBUG
   printf("Vals added in:\n   ");
   for (i = 0; i < n; i++)
      printf("%6.3e ", vals[i]);
   printf("\n");
#  endif

#  ifdef DEBUG
   free(vals);
#  endif
   free(thread_handles);
   return 0;
}  /* main */

/*------------------------------------------------------------------
 * Function:       Thread_sum
 * Purpose:        Add in the terms computed by the thread running this
 * In arg:         rank
 * Ret val:        ignored
 * Globals in:     n, thread_count
 * Global in/out:  sum
 */
void* Thread_sum(void* rank) {
   long my_rank = (long) rank;
   double factor;
   long long i;
   long long my_n = n/thread_count;
   long long my_first_i = my_n*my_rank;
   long long my_last_i = my_first_i + my_n;

   if (my_first_i % 2 == 0)
      factor = 1.0;
   else
      factor = -1.0;

   for (i = my_first_i; i < my_last_i; i++, factor = -factor) {
      while (flag != my_rank);
      sum += factor/(2*i+1);
#     ifdef DEBUG
      vals[i] = factor/(2*i+1);
#     endif
      if (my_rank == thread_count-1)
         flag = 0;
      else
         flag++;
   }



   return NULL;
}  /* Thread_sum */

/*------------------------------------------------------------------
 * Function:   Serial_pi
 * Purpose:    Estimate pi using 1 thread
 * In arg:     n
 * Return val: Estimate of pi using n terms of Maclaurin series
 */
double Serial_pi(long long n) {
   double sum = 0.0;
   long long i;
   double factor = 1.0;

   for (i = 0; i < n; i++, factor = -factor) {
      sum += factor/(2*i+1);
#     ifdef DEBUG
      vals[i] = factor/(2*i+1);
#     endif
   }
   return 4.0*sum;

}  /* Serial_pi */

/*------------------------------------------------------------------
 * Function:    Get_args
 * Purpose:     Get the command line args
 * In args:     argc, argv
 * Globals out: thread_count, n
 */
void Get_args(int argc, char* argv[]) {
   if (argc != 3) Usage(argv[0]);
   thread_count = strtol(argv[1], NULL, 10);
   if (thread_count <= 0 || thread_count > MAX_THREADS) Usage(argv[0]);
   n = strtoll(argv[2], NULL, 10);
   if (n <= 0) Usage(argv[0]);
}  /* Get_args */

/*------------------------------------------------------------------
 * Function:  Usage
 * Purpose:   Print a message explaining how to run the program
 * In arg:    prog_name
 */
void Usage(char* prog_name) {
   fprintf(stderr, "usage: %s <number of threads> <n>\n", prog_name);
   fprintf(stderr, "   n is the number of terms and should be >= 1\n");
   fprintf(stderr, "   n should be evenly divisible by the number of threads\n");
   exit(0);
}  /* Usage */
