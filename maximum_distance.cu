#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>

#define N 5

__global__ void calculate_distance(int *X, int *Y) {

	unsigned id1 = ( blockIdx.x * 30 + threadIdx.x ) / N;
	unsigned id2 = ( blockIdx.x * 30 + threadIdx.x % N ) % N + id1 + 1;
	
	if(id1 >= N || id2 >= N) return;
	
	int x1 = X[id1], y1 = Y[id1], x2 = X[id2], y2 = Y[id2];
	
	printf("\nx1 = %d, y1 = %d, x2 = %d, y2 = %d", x1, y1, x2, y2);
	
	float distance = sqrt((float) (x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1));
	
	printf("\ndistance = %f", distance);
}

int main() {
	
	int X[N], Y[N];
	int *dX, *dY;
	time_t t;
	
	srand((unsigned) time(&t));
	
	printf("The points are: \n");
	for(unsigned ii = 0; ii < N; ii++) {
		X[ii] = rand() % 10;
		Y[ii] = rand() % 10;
	}
	
	for(unsigned ii = 0; ii < N; ii++) {
		printf("(%d, %d), ", X[ii], Y[ii]);
	}
	
	cudaMalloc(&dX, N * sizeof(int));
	cudaMalloc(&dY, N * sizeof(int));
	
	cudaMemcpy(dX, X, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dY, Y, N * sizeof(int), cudaMemcpyHostToDevice);
	
	int nblocks = ceil((float) (N * (N - 1) / 2 ) / 30);
	
	printf("\nnblocks = %d\n", nblocks);
	
	calculate_distance<<<nblocks, 30>>>(dX, dY);
	cudaDeviceSynchronize();
	
	return 0;
}

// lets assume N threads. Then we launch the kernel with N^2 threads.
// Then we launch the kernel with 1024 threads and ceil(float) N*N / 1024) blocks.
// each kernel will have threadIdx.x from 0 to 1023, blockDim = N*N/1024 and blockIdx.x from 0 to N*N/1024 - 1

// we have x1 and x2 ranging from 0 to N each
// we need to find the distance between each pair of points and find the maximum distance.

// the pairs will be:
/*
	(0, 1)
	(0, 2)
	(0, 3)
	.
	.
	.
	.
	(1, 2)
	(1, 3)
	(1, 4)
	.
	.
	.
	.
	and so on.
	
	Each x1 starts with i and each corresponding x2 starts with i + 1 and goes up to N - 1
	
	threadId goes from 0 to 1023 and then block id changes.
	
	we have to combine blockId and threadId to make x1 and x2
	
	assume we have 50 ponts - 50 * 49 / 2 = 1225 pairs
	then we have 2 blocks, each block has 1024 threads from 0 to 1023
	
	the first thread has unique id (0, 0) where first 0 is blockid and second 0 is threadid
	
	x1 = X[threadIdx.x / N] x2 = X[blockIdx.x + threadIdx.x % N + 1];
	
	threadidx from 0 to 49 will give 0 for x1 and from 1 to 50 for x2
	
	then from 50 to 99, x1 = 1 and x2 will go from 1 to 50 again
	
	assume there are 30 threads in each block total
	
	then, from 0 to 29 we get x1 = 0 and x2 = 1 to 30
	
	then, blockid changes to 1 and threadid again goes frm 0 to 29, and x1 now is = 0 again, which does not work, since we need x1 to equal 0 from threadid 0 to 19, then 1 from threadid 20 onwards.
	
	
	
*/




























