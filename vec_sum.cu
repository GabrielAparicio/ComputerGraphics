#include<stdio.h>
#include<stdlib.h>

#define N 20
#define M 3


__global__ void sum(int *a, int *b, int *c, int n) {

	int index = threadIdx.x + blockIdx.x * blockDim.x;
	if (index < n)
 		c[index] = a[index] + b[index];
}

void fill_matrix(int *a, int n){
	int i;
	for(i=0;i<n;i++){
		a[i]=rand()%99;
	}
}

void print_matrix(int *a, int n){
	int i;
	for(i=0;i<n;i++){
		printf("%d ",a[i]);
	}
	printf("\n");
}

int main() 	
{

	int *a, *b, *c;
	int *d_a, *d_b, *d_c; 
	int size = N * sizeof(int);

	cudaMalloc((void **)&d_a, size);
	cudaMalloc((void **)&d_b, size);
	cudaMalloc((void **)&d_c, size);

	a = (int *)malloc(size); 
	fill_matrix(a, N);

	b = (int *)malloc(size);
 	fill_matrix(b, N);

	c = (int *)malloc(size);
	print_matrix(a,N);
	print_matrix(b,N); 

	cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

	sum<<<(N + M-1) / M,M>>>(d_a, d_b, d_c, N);

	cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

	print_matrix(c,N);

	free(a); 
	free(b); 
	free(c);

	cudaFree(d_a); 
	cudaFree(d_b); 
	cudaFree(d_c);

	return 0;
	
}

