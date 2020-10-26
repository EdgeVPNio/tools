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

Workspace_root=`pwd`
mkdir -p "$Workspace_root"/webrtc-checkout && cd "$Workspace_root"/webrtc-checkout
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

#install Toolchain according to OS
if [ "$target_os" == "ubuntu" ]; then
	sudo apt-get update && sudo apt-get -y install git python
	export PATH=$Workspace_root/webrtc-checkout/depot_tools:"$PATH"
else
	echo "export PATH=$Workspace_root/webrtc-checkout/depot_tools:\$PATH" | sudo tee /etc/profile.d/depot_tools.sh
fi

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
        ./src/build/install-build-deps.sh --no-chromeos-fonts
else
        ./src/build/install-build-deps.sh --no-chromeos-fonts
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

#gn_path=$Workspace_root/EdgeVPNIO/tools/bin/gn
if [ "$target_os" == "ubuntu" ]; then
	gn gen out/"$build_type" "--args=enable_iterator_debugging=false is_component_build=false is_debug=$debug_flag"
else
	gn gen out/"$build_type" "--args='target_os=\"linux\" target_cpu=\"arm\" is_debug=$debug_flag enable_iterator_debugging=false is_component_build=false"
fi

#ninja cmd to compile the required webrtc libraries
ninja -C out/"$build_type" boringssl boringssl_asm protobuf_lite rtc_p2p rtc_base_approved rtc_base jsoncpp rtc_event logging pc api rtc_pc_base call
