#!/bin/bash

#Build webrtc branch M84[4147] for debug/release on Debian

#basic parameter checks on script
helpFunction()
{
	echo ""
	echo "Usage: $0 -b build_type -t target"
	echo -e "\t-b build_type can be $build_type or debug"
	echo -e "\t-t target can be debian-x64 or debian-arm"
	exit 1 # Exit script after printing help
}

while getopts b:t: opt
do
	case "$opt" in
		b ) build_type="$OPTARG" ;;
		t ) target="$OPTARG" ;;
		? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
	esac
done

# Print helpFunction in case parameters are empty
if [ -z "$build_type" ] || [ -z "$target" ]
then
	echo "Some or all of the parameters are empty";
	helpFunction
fi
if [ "$build_type" != "debug" ] && [ "$build_type" != "$build_type" ]; then
	echo "Wrong build type spelling"
	helpFunction
elif [ "$target" != "debian-x64" ] && [ "$target" != "debian-arm" ]; then
	echo "Wrong target spelling"
	helpFunction
fi
#for gn cmd
debug_flag=false
if [ "$build_type" == "debug" ]; then
	debug_flag=true;
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

sudo apt-get install -y gtk2.0
echo Downloading Debian AMD64 sysroot
./src/build/linux/sysroot_scripts/install-sysroot.py --arch=x64
if [ "$target" == "debian-arm" ]; then
  echo Downloading Debian ARM sysroot
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
export PATH=$Workspace_root/webrtc-checkout/depot_tools/bootstrap-3.8.0.chromium.8_bin/python/bin:"$PATH"
#debian-x64 debug build
if [ "$target" == "debian-x64" ] && [ "$debug_flag" = true ]; then
	gn gen out/"$target"/"$build_type" "--args=enable_iterator_debugging=false is_debug=$debug_flag use_debug_fission=false"
#debian-x64 release build
elif [ "$target" == "debian-x64" ] && [ "$debug_flag" = false ]; then
	gn gen out/"$target"/"$build_type" "--args=enable_iterator_debugging=false is_debug=$debug_flag"
#raspberry-pi/debian-arm debug build
elif [ "$target" == "raspberry-pi" ] && [ "$debug_flag" = true ]; then
	gn gen out/"$target"/"$build_type" "--args=target_os=\"linux\" target_cpu=\"arm\" is_debug=$debug_flag enable_iterator_debugging=false use_debug_fission=false"
else 
#raspberry-pi/debian-arm release build
	gn gen out/"$target"/"$build_type" "--args=target_os=\"linux\" target_cpu=\"arm\" is_debug=$debug_flag enable_iterator_debugging=false"
fi

#ninja cmd to compile the required webrtc libraries
ninja -C out/"$target"/"$build_type" libc++ boringssl boringssl_asm protobuf_lite rtc_p2p rtc_base_approved rtc_base jsoncpp rtc_event logging pc api rtc_pc_base call
