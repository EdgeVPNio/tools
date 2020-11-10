#!/bin/bash

#basic parameter checks on script
helpFunction()
{
        echo ""
        echo "Usage: $0 -b build_type -t target_os"
        echo -e "\t-b build_type can be release or debug"
        echo -e "\t-t target_os can be ubuntu or raspberry-pi"
        exit 1 # Exit script after printing help
}
while getopts b:t: opt
do
        case "$opt" in
                b ) build_type="$OPTARG" ;;
                t ) target_os="$OPTARG" ;;
                ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
        esac
done

# Print helpFunction in case parameters are empty
if [ -z "$build_type" ] || [ -z "$target_os" ]
then
        echo "Some or all of the parameters are empty";
        helpFunction
fi
if [ "$build_type" != "debug" ] && [ "$build_type" != "release" ]; then
        echo "Wrong build_type spelling"
        helpFunction
elif [ "$target_os" != "ubuntu" ] && [ "$target_os" != "raspberry-pi" ]; then
        echo "Wrong OS type spelling"
        helpFunction
fi
#for gn cmd
debug_flag=false
if [ "$build_type" == "debug" ]; then
        $debug_flag = true;
fi

if [[ "$target_os" == "ubuntu" ]]; then
        platform="debian-x64"
elif [[ "$target_os" == "raspberry-pi" ]]; then
        platform="debian-arm"
fi

#assuming this script runs from a place a directory where all three -evio, tools,external exist
WrkspaceRoot=$(pwd)
cd "$WrkspaceRoot"/EdgeVPNio/evio/tincan
GN="$WrkspaceRoot"/EdgeVPNio/tools/bin/gn
#ubuntu debug build
if [ "$target_os" == "ubuntu" ] && [ "$debug_flag" = true ]; then
	$GN gen out/"$platform"/"$build_type" "--args=is_debug=$debug_flag target_sysroot_dir=\"\"$WrkspaceRoot\"/EdgeVPNio/external\" use_debug_fission=false clang_base_path=\"\"$WrkspaceRoot\"/EdgeVPNio/tools/llvm/bin"\"
#ubuntu release build
elif [ "$target_os" == "ubuntu" ] && [ "$debug_flag" = false ]; then
	$GN gen out/"$platform"/"$build_type" "--args=is_debug=$debug_flag target_sysroot_dir=\"\"$WrkspaceRoot\"/EdgeVPNio/external\" clang_base_path=\"\"$WrkspaceRoot\"/EdgeVPNio/tools/llvm/bin"\"
#raspberry-pi debug build
elif [ "$target_os" == "raspberry-pi" ] && [ "$debug_flag" = true ]; then
        $GN gen out/"$platform"/"$build_type" "--args=target_cpu=\"arm\" use_lld=true use_debug_fission=false target_sysroot_dir=\"\"$WrkspaceRoot\"/EdgeVPNio/external\" is_debug=$debug_flag clang_base_path=\"\"$WrkspaceRoot\"/EdgeVPNio/tools/llvm/bin\""
else
#raspberry-pi release build
	$GN gen out/"$platform"/"$build_type" "--args=target_cpu=\"arm\" use_lld=true target_sysroot_dir=\"\"$WrkspaceRoot\"/EdgeVPNio/external\" is_debug=$debug_flag clang_base_path=\"\"$WrkspaceRoot\"/EdgeVPNio/tools/llvm/bin\""
fi

ninja -C out/"$platform"/"$build_type"

