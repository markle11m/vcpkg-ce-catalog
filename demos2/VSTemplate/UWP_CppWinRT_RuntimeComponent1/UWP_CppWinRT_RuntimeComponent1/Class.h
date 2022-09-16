#pragma once

#include "Class.g.h"

namespace winrt::UWP_CppWinRT_RuntimeComponent1::implementation
{
    struct Class : ClassT<Class>
    {
        Class() = default;

        int32_t MyProperty();
        void MyProperty(int32_t value);
    };
}

namespace winrt::UWP_CppWinRT_RuntimeComponent1::factory_implementation
{
    struct Class : ClassT<Class, implementation::Class>
    {
    };
}
