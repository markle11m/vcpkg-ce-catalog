# Demo instructions

## Installation

To install these demos:

Create a demo directory and clone the vcpkg-ce-catalog repo containing the demos into it, then checkout the msvc-experiments-demos2 branch and cd into the demos2 directory. E.g.:
```
pushd c:\
if exist VcpkgDemos2 rd /s /q VcpkgDemos2
md c:\VcpkgDemos2
git clone https://github.com/markle11m/vcpkg-ce-catalog.git c:\VcpkgDemos2\msvc-experiments-demos
pushd c:\VcpkgDemos2\msvc-experiments-demos
git checkout msvc-experiments-demos
pushd demos2
```

## Setting up the demo environment

The demo directories are organized in a {**scenario**}\\{**toolset-acquisition-model**} hierarchy.
- In the root directory are scripts to setup a demo environment and also to reset the machine state.
- The first level of directories are scenarios. These are the current scenarios available:
  - *CommandLine-MSBuild*: Contains a VC++ solution buildable using msbuild.exe
  - *CommandLine-CL* : Contains a simple program buildable in a command-line environment using CL.exe
- The second level of directories are for toolset acquisition models:
  - *VcpkgArtifacts-VSIX*: Tools are acquired using vcpkg artifact support from the same .VSIX packages used by VS
  - *CoreXT-Init*: Tools are acquired using CoreXT's configuration file (default.config) and commands (init.cmd/init.ps1)

To set up a demo environment, go to the demo root directory and run set-demo-environment.cmd passing the scenario directory name, then cd into the toolset acquisition model directory you want to use and bootstrap your environment, e.g.:
```
set-demo-environment.cmd CommandLine-MSBuild
cd VcpkgArtifacts-VSIX
bootstrap
```

## Shortcut commands

The following macros are defined to assist in running demos. These macros rely on additional helper script to run the appropriate set of commands. 
By default, the scripts will show the command to be run and then pause before running the command. If you don't want the pause, `set _pause=no` in your
command shell.
| Shortcut | Description |
| ----------- | ----------- |
| reset_machine | Uninstall/remove per-user acquisition components |
| reset | Uninstall/remove both per-user and per-demo acquisition components |
| bootstrap | Install acquisition prerequisites (no build toolset components) |
| acquire | Download build toolset components |
| activate [{arch}] | Activate build environment for the target architecture |
| clean [{arch}] | Clean demo project |
| build [{arch}] | Build and run demo project |
| rebuild [{arch}] | Rebuild and run demo project |
| show_config | Show vcpkg-configuration.json file for this build demo |
| install_vcrt | Download and install latest VC runtime (system-wide install) |
| install_vs | Download and run the Visual Studio installer |
| help | Display this usage message |

## Full commands

Once the environment is setup, you can also run commands directly as you might in any other build environment. 
There are a set of commands listed in demo-script.txt that have been used in presentations by the VC team to show this demo.
