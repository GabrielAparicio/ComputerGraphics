#include <stdio.h>
#include <stdlib.h>}

#define N 20
#define RADIUS 3
#define BLOCK_SIZE 35

__global__ void stencil(int *in, int *out) {

	__shared__ int temp[BLOCK_SIZE + 2 * RADIUS];
 	int gindex = threadIdx.x + blockIdx.x * blockDim.x;
 	int lindex = threadIdx.x + radius;
 	// Read input elements into shared memory
 	temp[lindex] = in[gindex];

 	if (threadIdx.x < RADIUS) {
 	temp[lindex – RADIUS] = in[gindex – RADIUS];
 	temp[lindex + BLOCK_SIZE] = in[gindex + BLOCK_SIZE];
 	}

 	// Synchronize (ensure all the data is available)
 	__syncthreads();

 	// Apply the stencil
 	int result = 0;
 	for (int offset = -RADIUS ; offset <= RADIUS ; offset++)
 	result += temp[lindex + offset];
 	// Store the result
 	out[gindex] = result;
}


void fill_vec(int *a, int n){
	int i;
	for(i=1;i<=n;i++){
		//a[i]=rand()%99;
		a[i-1] = i;
	}
}

void print_vec(int *a, int n){
	int i;
	for(i=0;i<n;i++){
		printf("%d ",a[i]);
	}
	printf("\n");
}

int main()
{
	int *input,*output;
	int *d_input,*d_output;

	int size = N * sizeof(int);

	input = (int*) malloc(size);
	output = (int*) malloc(size);

	fill_vec(input, N);
	
	cudaMalloc((void **)&d_input, size);
	cudaMalloc((void **)&d_ouput, size);
	
	print_vec(input,N);

	cudaMemcpy(d_input, input, size, cudaMemcpyHostToDevice);


	stencil<<<(N+BLOCK_SIZE-1)/BLOCK_SIZE/,BLOCK_SIZE>>>(d_input, d_output);

	cudaMemcpy(output, d_output, size, cudaMemcpyDeviceToHost);

	print_vec(output,N);
	return 0;
}
