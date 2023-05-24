#include "devscc.h"
#include "sf-types.h"
#include "sh7708.h"
#include "e-types.h"

// int main(void) {
//   volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;

//   int a;
//   int b;
//   int c;
//   int i;

//   a = 6;
//   b = 3; 

//   c = a - b;
//   *gDebugLedsMemoryMappedRegister = 0xFF;

//     for (i = 0; i < c; i++) {
//       *gDebugLedsMemoryMappedRegister = ~(*gDebugLedsMemoryMappedRegister);
//     }
//   return 0;
// }

#define SIZE 10
void matrixMultiplication(int matrix1[SIZE][SIZE], int matrix2[SIZE][SIZE], int result[SIZE][SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            //matrix1[i][j] = matrix1[i][j] >> 1;
            //matrix2[i][j] = matrix2[i][j] << 1;

            if (matrix1[i][j] > matrix2[i][j]) {
                result[i][j] = matrix1[i][j] * matrix2[i][j];
            } else {
                result[i][j] = matrix2[i][j] + matrix1[i][j];
            }
        }
    }
}

int main() {
    volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;
    *gDebugLedsMemoryMappedRegister = 0xFF;

    int matrix1[SIZE][SIZE] = {
        {9, 3, 5, 0, 2, 3, 5, 6, 4, 8},
        {1, 3, 4, 2, 0, 7, 1, 5, 6, 9},
        {4, 8, 2, 6, 4, 7, 3, 0, 9, 2},
        {6, 1, 3, 8, 2, 1, 7, 4, 6, 5},
        {5, 0, 3, 2, 9, 6, 5, 1, 4, 7},
        {2, 8, 7, 4, 6, 0, 3, 5, 9, 1},
        {4, 6, 2, 7, 3, 9, 8, 1, 5, 0},
        {1, 5, 4, 9, 2, 6, 7, 3, 8, 0},
        {7, 3, 6, 1, 5, 0, 2, 4, 9, 8},
        {8, 9, 1, 4, 3, 5, 0, 6, 7, 2}
    };

    int matrix2[SIZE][SIZE] = {
        {2, 4, 9, 1, 7, 8, 5, 0, 3, 6},
        {3, 0, 6, 2, 1, 5, 4, 7, 9, 8},
        {1, 5, 3, 8, 9, 7, 0, 4, 6, 2},
        {8, 9, 2, 6, 4, 0, 7, 5, 3, 1},
        {0, 7, 1, 3, 6, 9, 4, 2, 5, 8},
        {6, 2, 8, 4, 5, 1, 3, 9, 7, 0},
        {5, 3, 9, 0, 2, 4, 1, 6, 8, 7},
        {9, 1, 5, 7, 3, 6, 8, 2, 0, 4},
        {4, 6, 7, 5, 8, 3, 2, 1, 0, 9},
        {7, 2, 4, 1, 6, 5, 3, 8, 0, 9}
    };

    int result[SIZE][SIZE];

    
    matrixMultiplication(matrix1, matrix2, result);
    *gDebugLedsMemoryMappedRegister = ~(*gDebugLedsMemoryMappedRegister);
    matrixMultiplication(matrix2, matrix1, result);
    *gDebugLedsMemoryMappedRegister = ~(*gDebugLedsMemoryMappedRegister);

    return 0;
}
