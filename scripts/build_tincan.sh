#!/bin/bash

#basic parameter checks on script
helpFunction()
{
        echo ""
        echo "Usage: $0 -b build_type -t target"
        echo -e "\t-b build_type can be release or debug"
        echo -e "\t-t target can be debian-x64 or debian-arm"
        exit 1 # Exit script after printing help
}
while getopts b:t: opt
do
        case "$opt" in
                b ) build_type="$OPTARG" ;;
                t ) target="$OPTARG" ;;
                ? ) helpFunction ;; # Print help if no parameter match
        esac
done

# Print helpFunction in case parameters are empty
if [ -z "$build_type" ] || [ -z "$target" ]
then
        echo "Some or all of the parameters are empty";
        helpFunction
fi
if [ "$build_type" != "debug" ] && [ "$build_type" != "release" ]; then
        echo "Wrong build_type spelling"
        helpFunction
elif [ "$target" != "debian-x64" ] && [ "$target" != "debian-arm" ]; then
        echo "Wrong OS type spelling"
        helpFunction
fi
#for gn cmd
debug_flag=false
fission_flag=true
if [ "$build_type" == "debug" ]; then
        debug_flag=true;
        fission_flag=false
fi

platform="$target"

#Assume all three directories - evio, tools, external - exist.
WrkspaceRoot=$(pwd)
cd "$WrkspaceRoot"/EdgeVPNio/evio/tincan
GN="$WrkspaceRoot"/EdgeVPNio/tools/bin/gn
NJ="$WrkspaceRoot"/EdgeVPNio/tools/bin/ninja
if [ "$target" == "debian-x64" ]; then
	$GN gen out/"$platform"/"$build_type" "--args=is_debug=$debug_flag target_sysroot_dir=\"$WrkspaceRoot/EdgeVPNio/external\" use_debug_fission=$fission_flag clang_base_path=\"$WrkspaceRoot/EdgeVPNio/tools/llvm/bin"\"

elif [ "$target" == "debian-arm" ]; then
        $GN gen out/"$platform"/"$build_type" "--args=target_cpu=\"arm\" use_lld=true use_debug_fission=$fission_flag target_sysroot_dir=\"$WrkspaceRoot/EdgeVPNio/external\" is_debug=$debug_flag clang_base_path=\"$WrkspaceRoot/EdgeVPNio/tools/llvm/bin\""
fi

$NJ -C out/"$platform"/"$build_type"

