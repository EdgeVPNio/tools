#!/bin/bash
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

if [[ "$target_os" == "ubuntu" ]]; then
        platform="debian-x64"
elif [[ "$target_os" == "raspberry-pi" ]]; then
        platform="debian-arm"
fi

mkdir -p out/$platform/external/include
#getting the required include files and folders from webrtc-checkout
# folders required: absl,api,base,call,common_video,logging,media,modules,p2p,pc,system_wrappers,rtc_base,build,common_types.h, jni.h, logging_buildflags.h
# Script to be run at workspace containing webrtc-checkout
mkdir -p  out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/third_party/abseil-cpp/absl out/$platform/external/include
cp -r webrtc-checkout/src/api  out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/base out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/call out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/common_video out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/logging/rtc_event_log out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/media out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/modules out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/p2p out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/pc out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/system_wrappers out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/rtc_base out/$platform/external/include/webrtc
cp -r webrtc-checkout/src/third_party/jsoncpp/source/include/json out/$platform/external/include
cp webrtc-checkout/src/third_party/jsoncpp/generated/version.h out/$platform/external/include/json
cp webrtc-checkout/src/common_types.h out/$platform/external/include/webrtc
cp webrtc-checkout/src/third_party/ffmpeg/libavcodec/jni.h out/$platform/external/include/webrtc
mkdir -p  out/$platform/external/include/libc++
mkdir -p  out/$platform/external/include/libc++abi
cp -r webrtc-checkout/src/buildtools/third_party/libc++/trunk/include out/$platform/external/include/libc++
cp -r webrtc-checkout/src/buildtools/third_party/libc++abi/trunk/include out/$platform/external/include/libc++abi
#command to remove all files other than *.h
cd out/$platform/external/include
find . -type f ! -name '*.h' -delete

#mkdir -p /external/include/build && cp webrtc-checkout/src/build/build_config.h "$_"
#cp webrtc-checkout/src/build/buildflag.h /external/include/build
