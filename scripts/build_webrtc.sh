#!/bin/bash
#Ensure git works in the setup
#steps to install webrtc M84[4147] version for debug/release build_type on ubuntu/raspberry-pi target os


#basic parameter checks on script
helpFunction()
{
	echo ""
	echo "Usage: $0 -b build_type -t target_os"
	echo -e "\t-b build_type can be $build_type or debug"
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
if [ "$build_type" != "debug" ] && [ "$build_type" != "$build_type" ]; then
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

Workspace_root=`pwd`
mkdir -p "$Workspace_root"/webrtc-checkout && cd "$Workspace_root"/webrtc-checkout
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

export PATH=$Workspace_root/webrtc-checkout/depot_tools:"$PATH"

#To update the setup with depot_tools in path
errormsg=$( gclient sync 2>&1)
if [[ "$errormsg" == *"error"* ]]; then
        echo $errormsg
        exit 1;
fi

#build webrtc
errormsg=$( fetch --nohooks webrtc 2>&1)
if [[ "$errormsg" == *"error"* ]]; then
        echo $errormsg
        exit 1;
fi

if [ "$target_os" == "ubuntu" ]; then
        sudo apt-get install gtk2.0
        ./src/build/linux/sysroot_scripts/install-sysroot.py --arch=x64
else
        ./src/build/linux/sysroot_scripts/install-sysroot.py --arch=arm
fi

cd src
git checkout branch-heads/4147

#to update the path to depot_tools/gn and ninja
errormsg=$( gclient sync 2>&1)
if [[ "$errormsg" == *"error"* ]]; then
        echo $errormsg
        exit 1;
fi

#ubuntu debug build
if [ "$target_os" == "ubuntu" ] && [ "$debug_flag" = true ]; then
	gn gen out/"$platform"/"$build_type" "--args=enable_iterator_debugging=false is_debug=$debug_flag use_debug_fission=false"
#ubuntu release build
elif [ "$target_os" == "ubuntu" ] && [ "$debug_flag" = false ]; then
	gn gen out/"$platform"/"$build_type" "--args=enable_iterator_debugging=false is_debug=$debug_flag"
#raspberry-pi debug build
elif [ "$target_os" == "raspberry-pi" ] && [ "$debug_flag" = true ]; then
	gn gen out/"$platform"/"$build_type" "--args=target_os=\"linux\" target_cpu=\"arm\" is_debug=$debug_flag enable_iterator_debugging=false use_debug_fission=false"
else 
#raspberry-pi release build
	gn gen out/"$platform"/"$build_type" "--args=target_os=\"linux\" target_cpu=\"arm\" is_debug=$debug_flag enable_iterator_debugging=false"
fi

#ninja cmd to compile the required webrtc libraries
ninja -C out/"$platform"/"$build_type" libc++ boringssl boringssl_asm protobuf_lite rtc_p2p rtc_base_approved rtc_base jsoncpp rtc_event logging pc api rtc_pc_base call
