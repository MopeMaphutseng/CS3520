// CS3520 Lab 2, Exercise 4
// C++ model: factorial of N computed by a procedure that main() calls.
// Written first, tested, then translated to RISC-V assembly.

#include <iostream>

int factorial(int n)
{
    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

int main()
{
    int n = 5;
    std::cout << "Factorial: " << factorial(n) << std::endl;
    return 0;
}