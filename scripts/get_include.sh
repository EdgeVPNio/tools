#!/bin/bash
# Adds the include headers @ out/external directory

#getting the required include files and folders from webrtc-checkout
# folders required: absl,api,base,call,common_video,logging,media,modules,p2p,pc,system_wrappers,rtc_base,build,common_types.h, jni.h, logging_buildflags.h

# Script to be run at workspace containing webrtc-checkout

#parameter: $1: src directory, $2: dest directory
#Copies the header files recursively from source webrtc to external/include
copyHeaders()
{
	#enable -v if verbose is required
	mkdir -p $2
	rsync -am --include='*.h' -f 'hide,! */' $1 $2
}

copyHeaders webrtc-checkout/src/third_party/abseil-cpp/absl out/external/include
copyHeaders webrtc-checkout/src/third_party/abseil-cpp/absl out/external/include
copyHeaders webrtc-checkout/src/api  out/external/include/webrtc
copyHeaders webrtc-checkout/src/base out/external/include/webrtc
copyHeaders webrtc-checkout/src/call out/external/include/webrtc
copyHeaders webrtc-checkout/src/common_video out/external/include/webrtc
copyHeaders webrtc-checkout/src/logging/rtc_event_log out/external/include/webrtc
copyHeaders webrtc-checkout/src/media out/external/include/webrtc
copyHeaders webrtc-checkout/src/modules out/external/include/webrtc
copyHeaders webrtc-checkout/src/p2p out/external/include/webrtc
copyHeaders webrtc-checkout/src/pc out/external/include/webrtc
copyHeaders webrtc-checkout/src/system_wrappers out/external/include/webrtc
copyHeaders webrtc-checkout/src/rtc_base out/external/include/webrtc
copyHeaders webrtc-checkout/src/third_party/jsoncpp/source/include/json out/external/include
copyHeaders webrtc-checkout/src/third_party/jsoncpp/generated/version.h out/external/include/json
copyHeaders webrtc-checkout/src/common_types.h out/external/include/webrtc
copyHeaders webrtc-checkout/src/third_party/ffmpeg/libavcodec/jni.h out/external/include/webrtc
#files other than *.h
mkdir -p  out/external/include/libc++
mkdir -p  out/external/include/libc++abi
cp -r webrtc-checkout/src/buildtools/third_party/libc++/trunk/include out/external/include/libc++
cp -r webrtc-checkout/src/buildtools/third_party/libc++abi/trunk/include out/external/include/libc++abi
#mkdir -p /external/include/build && cp webrtc-checkout/src/build/build_config.h "$_"
#cp webrtc-checkout/src/build/buildflag.h /external/include/build
