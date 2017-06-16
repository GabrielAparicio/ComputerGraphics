#include <stdio.h>
#include <stdlib.h>

// Implementación de la suma y multiplicación de matrices, dim3, punteros dobles

#define N 6
#define THREADS_PER_BLOCK 16


__global__
void matrix_add(int** dd_mat_a,int** dd_mat_b,int** dd_mat_c, int n)
{

        int cols = threadIdx.x + blockIdx.x*blockDim.x;
        int fils = threadIdx.y + blockIdx.y*blockDim.y;

        if( fils <n && cols < n ){
        dd_mat_c[fils][cols] = dd_mat_a[fils][cols] + dd_mat_b[fils][cols];
        }

}

__global__
void matrix_mult(int** dd_mat_a,int** dd_mat_b,int** dd_mat_c, int n)
{
        int cols = threadIdx.x + blockIdx.x*blockDim.x;
        int fils = threadIdx.y + blockIdx.y*blockDim.y;

        int i;
        if(fils < n && cols < n)
        {
        dd_mat_c[fils][cols] = 0;
        for(i=0;i<n;i++)
        {
        dd_mat_c[fils][cols] += dd_mat_a[fils][i]*dd_mat_b[i][cols];
        }
        }
}


void create_host_matrix(int*** mat,int n, int m){
        *mat = (int** )malloc(sizeof(int*)*n);
        (*mat)[0] = (int* )malloc(sizeof(int)*n*m);
        int i;
        for(i=1;i<n;i++){
                (*mat)[i] = (*mat)[0]+i*m;
        }
}



void fill_host_matrix(int** mat, int n, int m){
        int i,j;
        for(i=0; i<n ;i++){
                for(j=0; j<m ;j++)
                        //mat[i][j] = rand()%2+1;
                        mat[i][j] = 1;
        }
}

void fill_zero(int** mat,int n, int m, int value=0){
        int i,j;
        for(i=0;i<n;i++)
                for(j=0;j<m;j++)
                        mat[i][j] = value;
}


void print(int** mat,int n, int m){
        int i,j;
        for(i=0; i<n ;i++){
                for(j=0; j<m ;j++)
                        printf("%d ",mat[i][j]);
                printf("\n");
        }
}

void create_matrices(int** &mat_a,int** &d_mat_a,int** &dd_mat_a,int n,int m)
{
        int i;

        int size_row = sizeof(int*) * n;
        int size_col = sizeof(int ) * m;

        create_host_matrix(&mat_a,n,m);
        fill_host_matrix(mat_a,n,m);

        d_mat_a = (int**) malloc(size_row);
        cudaMalloc((void**)& d_mat_a[0], sizeof(int) * m * n );
        cudaMemcpy(d_mat_a[0], mat_a[0], sizeof(int) * m * n ,cudaMemcpyHostToDevice);

        for(i=1;i<n;i++){
                d_mat_a[i]=(d_mat_a[i-1]+m);
        }

        cudaMalloc((void***)&dd_mat_a,size_row);
        cudaMemcpy(dd_mat_a,d_mat_a,size_row,cudaMemcpyHostToDevice);

}

int main()
{

        int** mat_a; int** d_mat_a;      int** dd_mat_a;
        int** mat_b; int** d_mat_b;      int** dd_mat_b;
        int** mat_c; int** d_mat_c;      int** dd_mat_c;

        int i;
        int size_row = sizeof(int*) * N;
        int size_col = sizeof(int ) * N;


        create_matrices(mat_a,d_mat_a,dd_mat_a,N,N);
        create_matrices(mat_b,d_mat_b,dd_mat_b,N,N);
        create_matrices(mat_c,d_mat_c,dd_mat_c,N,N);

        printf("Matrix A\n");
        print(mat_a,N,N);
        printf("\n");

        printf("Matrix B\n");
        
        print(mat_b,N,N);
        printf("\n");

        dim3 my_block(THREADS_PER_BLOCK,THREADS_PER_BLOCK);
        dim3 my_grid((N + my_block.x-1)/my_block.x, (N + my_block.y-1)/my_block.y);


        //matrix_mult<<<my_grid,my_block>>>(dd_mat_a,dd_mat_b,dd_mat_c,N);
        matrix_mult_shared<<<my_grid,my_block>>>(dd_mat_a,dd_mat_b,dd_mat_c,N);
        for(i=0;i<N;i++){
                cudaMemcpy(mat_c[i],d_mat_c[i],size_col,cudaMemcpyDeviceToHost);
        }

        printf("\n");
        printf("Matrix C \n");
        print(mat_c,N,N);
        return 0;
}
