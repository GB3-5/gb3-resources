// void flash_fast() { 
//     volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;
//     *gDebugLedsMemoryMappedRegister = 0xFF;
//     for (int k = 0; k < 6; k++) {
//         //Null statement to waste time
//         *gDebugLedsMemoryMappedRegister = ~(*gDebugLedsMemoryMappedRegister);
//         for (int j = 0; j < 10000; j++) {
//         //Null statement to waste time
//         ;
//         }
//     }
// }

// void flash_slow() { 
//     volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;
//     *gDebugLedsMemoryMappedRegister = 0xFF;
//     for (int j = 0; j < 100000; j++) {
//         ;
//     }
//     *gDebugLedsMemoryMappedRegister = ~(*gDebugLedsMemoryMappedRegister);
//     for (int l = 0; l < 100000; l++) {
//         ;
//     }
// }

// int main() { 
//     int a = 1;
//     int b = 3;
//     int sum = 0; 

//     sum = a + b;
//     if (sum == 4) {
//         flash_slow();
//     } else {
//         flash_fast();
//     }

//     a = 717225898; 
//     b = 717225898;

//     sum = a + b;
//     if (sum == 1434451796) {
//         flash_slow();
//     } else {
//         flash_fast();
//     }

//     a = 5; 
//     b = 1; 
//     sum = a - b;
//     if (sum == 4) {
//         flash_slow();
//     } else {
//         flash_fast();
//     }

//     a = 715827882; 
//     b = 357913941; 
//     sum = a - b;
//     if (sum == 357913941) {
//         flash_slow();
//     } else {
//         flash_fast();
//     }

//     return 0;
// }


int main() {
    int a = 200;
    int b = 100;
    int result = 0;
    volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;
    *gDebugLedsMemoryMappedRegister = 0xFF;

    // Arithmetic operations
    for (int i = 0; i < 10000; i++) {
        result = a + b;
        result = a - b;
        result = a * b;
        result = a / b;
        result = a % b;

        a++;
        b--;
    }

    // Logical operations
    for (int i = 0; i < 10000; i++) {
        result = a & b;
        result = a | b;
        result = a ^ b;
        result = ~a;

        a++;
        b--;
    }

    // Bitwise operations
    for (int i = 0; i < 10000; i++) {
        result = a << 1;
        result = b >> 1;
        result = a & ~b;

        a++;
        b--;
    }

    // Comparisons
    for (int i = 0; i < 10000; i++) {
        result = (a == b);
        result = (a != b);
        result = (a > b);
        result = (a < b);
        result = (a >= b);
        result = (a <= b);

        a++;
        b--;
    }

    // Conditional operations
    for (int i = 0; i < 10000; i++) {
        result = (a > b) ? a : b;
        result = (a < b) ? a : b;

        a++;
        b--;
    }
    
    *gDebugLedsMemoryMappedRegister = ~(*gDebugLedsMemoryMappedRegister);

    for (int j = 0; j < 1000000; j++) {
    //Null statement to waste time
    ;
    }
    return 0;
}