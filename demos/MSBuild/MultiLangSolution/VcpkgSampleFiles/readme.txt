This directory contains sample files for enabling vcpkg artifacts usage in this project.

Files:

Directory.Build.props:			
    Implicit import (MSBuild 15.0+) file for setting properties common to its directory and subdirectories
    MSBuild searches up the directory tree for it; i.e., lower Directory.Build.props files in the tree override higher ones

EnableVcpkgArtifacts.props:		
    Standalone file defining properties needed to enable vcpkg artifact integration with MSBuild 

vcpkg-configuration.json:	
    Reference version of vcpkg-configuration.json that shows multiple types of registry access (public, msft-private, dev-private, local) 
    and artifact demands:
        msbuild-bootstrap:  used for MSBuild-specific environment setup; i.e., 'vcpkg activate --tag:msbuild-bootstrap' 
                            activates MSBuild, Roslyn, etc. as specified
        msbuild-only:       used by MSBuild to set essential properties for the C++ toolset and Windows SDK (in the .vcpkg subdir) when 
                            building the project graph (first two passes of MSBuild)
        headers:            used for VC IDE design time integration (i.e., getting headers for Intellisense)
        {not tag}:          used for general environment activation
                            invoked by MSBuild to set its build environment when vcpkg integration is enabled; also can be used 
                            on the command line to set PATH/LIB/INCLUDE to include the C++ toolset and Windows SDK 




