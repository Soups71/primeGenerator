#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <fstream>
using namespace std;
// CUDA kernel. Each thread takes care of one element of c
// If the number at that index is prime then the value in c is set to that value. Value is set to 0 otherwise
__global__ void checkPrimes(unsigned long long int* a, unsigned long long int* c, unsigned long long int n)
{
    // Get our global thread ID
    int id = blockIdx.x * blockDim.x + threadIdx.x;

    // Make sure we do not go out of bounds
    if (id < n) {
        // Set's value of c to that of a
        c[id] = a[id];
        // Checks if number is zero or 1. These are not prime numbers
        if (a[id] == 0 || a[id] == 1) {
            		c[id] =0;
            	}
            	for(int i = 2; i <= a[id] / 2; i++){
            		if (a[id] % i == 0){
            			c[id] = 0;
                        break;
            		}
            	}
    }
}

int main(int argc, char* argv[])
{
    // File operators
    ofstream primeFile;
    primeFile.open("primes.txt");
    
    unsigned long long int n = 1000000;
    //USER I/O
    cout << "Please enter the number you would like to find primes of: ";
    cin >> n;
    cout << "You have entered the number : " << n<<endl;
    cout << "Beginning the process of finding prime numbers between 0 and " << n << endl;
    size_t bytes = n * sizeof(unsigned long long int);
    // Host input vector
    unsigned long long int* h_a;
    // Host output vector
    unsigned long long int* h_c;
    // Allocate memory for vectors
    h_a = (unsigned long long int*)malloc(bytes);
    h_c = (unsigned long long int*)malloc(bytes);

    // Device input vectors
    unsigned long long int* d_a;
    //Device output vector
    unsigned long long int* d_c;

    // Allocate memory for each vector on GPU
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_c, bytes);
    
    unsigned long long int i;
    
    // Initialize vectors on host
    cout << "Creating array of values" << endl;
    for (i = 0; i < n; i++) {
        //cout << i << endl;
        h_a[i] = i;
        //cout << i << endl;
    }
    cout << "Finished Generating the list" << endl;

    // Copy host vectors to device
    cout << "Passing memory to GPU" << endl;
    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);

    int blockSize, gridSize;

    // Number of threads in each thread block
    blockSize = 1024;

    // Number of thread blocks in grid
    gridSize = (int)ceil((float)n / blockSize);

    cout << "Beginning the check for primes" << endl;
    // Execute the kernel
    checkPrimes << <gridSize, blockSize >> > (d_a, d_c, n);

    // Copy array back to host
    cout << "Returning results back to CPU" << endl;
    cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);

    // Write prime numbers to file
    cout << "Printing results to file. H_c[23]:  "<<h_c[23] << endl;
    for (i = 0; i < n; i++) {
        if (h_c[i] != 0) {
            primeFile << h_c[i] << "\n";
            cout << h_c[i] << endl;
        }
        
    }
    cout << "Just about done. Beginning to clear Memory" << endl;


    // Clean up memory and close file
    // Release device memory
    cudaFree(d_a);
    cudaFree(d_c);

    // Release host memory
    free(h_a);
    free(h_c);

    cout << "Closing the file" << endl;
    primeFile.close();
    return 0;
}
