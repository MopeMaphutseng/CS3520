// CS3520 Lab 2, Exercise 1
// C++ model: print the larger of two integers.
// Written first, tested, then translated to RISC-V assembly.

#include <iostream>

int main()
{
    int a = 17;
    int b = 42;

    int larger;
    if (a >= b) {
        larger = a;
    } else {
        larger = b;
    }

    std::cout << "Larger: " << larger << std::endl;
    return 0;
}