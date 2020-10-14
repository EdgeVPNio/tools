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


#mkdir -p ~/workspace
#cd ~/workspace
#assuming this script runs from a place a directory where all three -evio, tools,external exist

git clone https://github.com/EdgeVPNio/evio.git
if [[ "$target_os" == "ubuntu" ]]; then
	git clone -b debian-x64 --single-branch https://github.com/EdgeVPNio/external.git
elif [[ "$target_os" == "raspberry-pi" ]]; then
        git clone -b debian-arm --single-branch https://github.com/EdgeVPNio/external.git
fi
#Todo: add git clone cmd for different OS
git clone https://github.com/EdgeVPNio/tools.git

cd evio/tincan
export PATH=`pwd`/../../tools/bin:$PATH

if [[ "$target_os" == "ubuntu" ]]; then
	gn gen out/debian-x64/$build_type "--args='is_debug=$debug_flag target_sysroot_dir=\"\'pwd\'/../../external\" use_debug_fission=false clang_base_path=\"\'pwd\'/../../tools/llvm/bin\""
        ninja -C out/debian-x64/$build_type
else
        gn gen out/debian-arm/$build_type "--args='target_cpu=\"arm\" is_debug=$debug_flag use_lld=true target_sysroot_dir=\"\'pwd\'/../../external\" is_debug=$debug_flag clang_base_path=\"\'pwd\'/../../tools/llvm/bin\""
	ninja -C out/debian-arm/$build_type
fi

