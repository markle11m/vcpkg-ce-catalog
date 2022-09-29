#include <stdio.h>
#include <iostream>
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

int main()
{
    HelloCStyle();
    HelloCppStyle();
    HelloASAN();
    return 0;
}