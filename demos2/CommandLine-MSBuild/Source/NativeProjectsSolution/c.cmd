@if "%_echo%"=="" echo off
call D:\VS\src\tools\X86\kill.exe msbuild.exe
call D:\VS\src\tools\X86\kill.exe mspdbsrv.exe
call D:\VS\src\tools\DevDiv\X86\delnode.exe /q .vcpkg
call D:\VS\src\tools\DevDiv\X86\delnode.exe /q Outputs
call D:\VS\src\tools\DevDiv\X86\delnode.exe /q C:\Users\olgaark\.vcpkg\artifacts
echo Done     	
