#include <stdio.h>
#include <iostream>
#include <atlstr.h>

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

int HelloATLStyle(void)
{
    CString cString = "Hello from ATL";
    printf("%s, using printf [function %s]\n", cString.GetString(), __FUNCTION__);
    return 1;
}

int main()
{
    HelloCStyle();
    HelloCppStyle();
    HelloATLStyle();
    return 0;
}