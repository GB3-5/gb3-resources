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

#define SIZE 5
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
        {9, 3, 5, 0, 2},
        {1, 3, 4, 2, 0},
        {4, 8, 2, 6, 4},
        {6, 1, 3, 8, 2},
        {5, 0, 3, 2, 9},
    };

    int matrix2[SIZE][SIZE] = {
        {2, 4, 9, 1, 7},
        {3, 0, 6, 2, 1},
        {1, 5, 3, 8, 9},
        {8, 9, 2, 6, 4},
        {0, 7, 1, 3, 6},
    };

    int result[SIZE][SIZE];

    
    matrixMultiplication(matrix1, matrix2, result);
    *gDebugLedsMemoryMappedRegister = ~(*gDebugLedsMemoryMappedRegister);
    
    for (int k = 0; k < 100000; k++) {
        //Null statement to waste time
        ;
    }
    return 0;
}
