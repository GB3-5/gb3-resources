
// #define TAKEN 1
// #define NOT_TAKEN 0
// #define STRONGLY_TAKEN 3
// #define WEAKLY_TAKEN 2
// #define STRONGLY_NOT_TAKEN 0
// #define WEAKLY_NOT_TAKEN 1

int testFunction(int a, int b) {
    int result = 0;
    if (a > b) {
        result = a - b;
    } else {
        result = b - a;
    }
    return result;
}

void testLocalBranchPredictor() {
    int i;
    int a = 5;
    int b = 10;
    int result = 0;
    int counter[2] = {2, 1};

    for (i = 0; i < 100000; i++) {
        if (counter[i % 2] >= 3) {
            result += testFunction(a, b);
            counter[i % 2]--;
        } else if (counter[i % 2] <= 0) {
            result += testFunction(b, a);
            counter[i % 2]++;
        } else if (counter[i % 2] == 2) {
            result += testFunction(a, b);
            counter[i % 2]--;
        } else if (counter[i % 2] == 1) {
            result += testFunction(b, a);
            counter[i % 2]++;
        }
    }
}

void testGlobalBranchPredictor () { 
    int sum1 = 0;
    int sum2 = 0;
    int sum3 = 0;
    for (int i = 0; i < 10000; i++) {
        if (i % 2 == 0) {
            sum1 += i;
        }

        if (i % 3 == 0) {
            sum2 += i;
        } 

        if (i % 5 == 0) {
            sum3 -= i;
        }
    }
}

int main() {
    // volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;
    // *gDebugLedsMemoryMappedRegister = 0xFF;
    testGlobalBranchPredictor();
    testLocalBranchPredictor();
    // *gDebugLedsMemoryMappedRegister = ~(*gDebugLedsMemoryMappedRegister);
    for (int j = 0; j < 1000000; j++) {
    //Null statement to waste time
    ;
    }
    return 0;
}