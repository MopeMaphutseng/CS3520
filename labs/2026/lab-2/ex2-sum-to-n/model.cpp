// CS3520 Lab 2, Exercise 2
// C++ model: compute the sum of the first N integers for N stored in memory.
// Written first, tested, then translated to RISC-V assembly.

#include <iostream>

int main()
{
    int n = 10;      // "stored in memory" in the assembly version

    int sum = 0;
    int i = 1;
    while (i <= n) {
        sum += i;
        i++;
    }

    std::cout << "Sum: " << sum << std::endl;
    return 0;
}