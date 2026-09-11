// CS3520 Lab 2, Exercise 5
// C++ model: greatest common divisor via Euclid's algorithm, written as a
// procedure that main calls. Written first, tested, then translated.
// Euclid: while (b != 0) { r = a % b; a = b; b = r; } return a;

#include <iostream>

int gcd(int a, int b)
{
    while (b != 0) {
        int r = a % b;
        a = b;
        b = r;
    }
    return a;
}

int main()
{
    int x = 84;
    int y = 30;
    std::cout << "GCD: " << gcd(x, y) << std::endl;
    return 0;
}