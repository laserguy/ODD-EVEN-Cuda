#include<stdio.h>
#include<iostream>
#include<conio.h>
#include <random>
#include <stdint.h>
#include <driver_types.h >

static __device__ __inline__ uint32_t __mysmid(){
	uint32_t smid;
	asm volatile("mov.u32 %0 , %%smid;" : "=r"(smid));
	return smid;
}

static __device__ __inline__ uint32_t __mywarpid(){
	uint32_t warpid;
	asm volatile("mov.u32 %0 , %%warpid;" : "=r"(warpid));
	return warpid;
}

static __device__ __inline__ uint32_t __mylaneid(){
	uint32_t laneid;
	asm volatile("mov.u32 %0 , %%laneid;" : "=r"(laneid));
	return laneid;
}


__global__ void odd(int *arr,int n){
  	int i=threadIdx.x;
  	int temp;
  	if(i%2==1&&i<n-1){
  	if(arr[i]>arr[i+1])
  	{
  		temp=arr[i];
  		arr[i]=arr[i+1];
  		arr[i+1]=temp;
  	}
  	printf("Odd thread %d SMID=%d warp ID=%d warp lane ID=%d \n",i,__mysmid(),__mywarpid(),__mylaneid());
  	}
}

__global__ void even(int *arr,int n){
  	int i=threadIdx.x;
  	int temp;
  	if(i%2==0&&i<n-1){
  	if(arr[i]>arr[i+1])
  	{
  		temp=arr[i];
  		arr[i]=arr[i+1];
  		arr[i+1]=temp;
  	}
  	printf("Even thread %d SMID=%d warp ID=%d warp lane ID=%d \n",i,__mysmid(),__mywarpid(),__mylaneid());
  	}
}

int main(){
	int SIZE,k,*A,p,j;
	int *d_A;
	float time;
	cudaEvent_t start, stop;
	
	printf("Enter the size of the array\n");
	scanf("%d",&SIZE);
	A=(int *)malloc(SIZE*sizeof(int));
	cudaMalloc(&d_A,SIZE*sizeof(int));
	for(k=0;k<SIZE;k++)
		//scanf("%d",&A[k]);
		A[k]=rand()%1000;
		
	
	cudaMemcpy(d_A,A,SIZE*sizeof(int),cudaMemcpyHostToDevice);
	if(SIZE%2==0)
		p=SIZE/2;
	else
		p=SIZE/2+1;

	cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

	for(j=0;j<p;j++){
		even<<<3,SIZE>>>(d_A,SIZE);
		if(j!=p-1)
			odd<<<3,SIZE>>>(d_A,SIZE);
		if(j==p-1&&SIZE%2==0)
			odd<<<1,SIZE>>>(d_A,SIZE);
	}

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time, start, stop);

	cudaMemcpy(A,d_A,SIZE*sizeof(int),cudaMemcpyDeviceToHost);
	for(k=0;k<SIZE;k++)
		printf("%d ",A[k]);
	
	printf("\nTime to generate:  %3.1f ms \n", time);
	free(A);
	cudaFree(d_A);
	
	getch();
	
}
