// CS3520 Lab 2, Exercise 3
// C++ model: count how many elements of an array are even, and print the count.
// Written first, tested, then translated to RISC-V assembly.

#include <iostream>

int main()
{
    int array[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int n = 10;

    int count = 0;
    for (int i = 0; i < n; i++) {
        if ((array[i] & 1) == 0) {   // even  <->  bit 0 is clear
            count++;
        }
    }

    std::cout << "Even count: " << count << std::endl;
    return 0;
}