#define STRONGLY_TAKEN 3
#define WEAKLY_TAKEN 2
#define WEAKLY_NOT_TAKEN 1
#define STRONGLY_NOT_TAKEN 0

int main() {
    int i;
    int j;
    int sum = 0;
    int counter = STRONGLY_TAKEN;  // Initial counter value
    volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;
    *gDebugLedsMemoryMappedRegister = 0xFF;

    for (i = 0; i < 50000; i++) {
        //printf("Iteration %d\n", i);
        
        if (counter >= WEAKLY_TAKEN) {
            // This condition causes weakly taken behavior
            //printf("Branch taken\n");
            counter++;  // Increment counter
        } else {
            // This condition causes weakly not taken behavior
            //printf("Branch not taken\n");
            counter--;  // Decrement counter
        }
        
        // Additional non-obvious conditional statements
        if (i % 100 == 0) {
            // This conditional statement flips the branch predictor from weakly taken to weakly not taken
            if (counter >= WEAKLY_TAKEN)
                counter = STRONGLY_NOT_TAKEN;
            else
                counter = STRONGLY_TAKEN;
        }
        
        //printf("\n");
    }
    *gDebugLedsMemoryMappedRegister = ~(*gDebugLedsMemoryMappedRegister);

    for (j = 0; j < 1000000; j++) {
        ;
  }
    
    return 0;
}