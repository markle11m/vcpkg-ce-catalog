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

int main()
{
    HelloCStyle();
    HelloCppStyle();
    return 0;
}