// HelloCpp-Vcpkg2-Nested.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <stdio.h>
using namespace std;

int HelloCStyle(void)
{
    printf("Hello from C, using printf [function %s]\n", __FUNCTION__);
    return 1;
}

int HelloCppStyle(void)
{
    cout << "Hello from C++, using cout [function " << __FUNCTION__ << "]" << endl;
    return 2;
}

int x[100];
int HelloASAN(void)
{
    printf("Hello from ASAN, gonna crash now...!\n");
    x[100] = 5; // Boom!
    return 0;
}

int HelloFromEveryone()
{
    HelloCStyle();
    HelloCppStyle();
    HelloASAN();
    return 0;
}

int main()
{
    std::cout << "Hello World! (Vcpkg2-Nested)\n";
    HelloFromEveryone();
}

// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file