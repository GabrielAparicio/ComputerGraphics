#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define m 10
#define n 5


__global__ void matrix_sum(int A[], int B[], int C[], int fil, int col) 
{
   
   int my_ij = blockDim.x * blockIdx.x + threadIdx.x;

   if (blockIdx.x < fil && threadIdx.x < col) 
      C[my_ij] = A[my_ij] + B[my_ij];
} 



void fill_matrix(int A[], int fil, int col) {
   int i, j;

   for (i = 0; i < fil; i++) {
      for (j = 0; j < col; j++)
         A[i*n+j] = rand()%99;
   } 
}

void print_matrix(int A[], int fil, int col) {
   int i, j;

   for (i = 0; i < fil; i++) {
      for (j = 0; j < col; j++)
         printf("%d ", A[i*n+j]);
      printf("\n");
   }  
}

int main(int argc, char* argv[]) {

   int *h_A, *h_B, *h_C;
   int *d_A, *d_B, *d_C;
   size_t size;

   
   size = m*n*sizeof(int);

   h_A = (int*) malloc(size);
   h_B = (int*) malloc(size);
   h_C = (int*) malloc(size);
   
   fill_matrix(h_A, m, n);
   fill_matrix(h_B, m, n);

   print_matrix(h_A, m, n);
   printf("\n");
   print_matrix(h_B, m, n);
   printf("\n");
   
   cudaMalloc((void **)&d_A, size);
   cudaMalloc((void **)&d_B, size);
   cudaMalloc((void **)&d_C, size);

   
   cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
   cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

   matrix_sum<<<m, n>>>(d_A, d_B, d_C, m, n);

   cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

   print_matrix(h_C, m, n);

   cudaFree(d_A);
   cudaFree(d_B);
   cudaFree(d_C);

   free(h_A);
   free(h_B);
   free(h_C);

   return 0;
}  
