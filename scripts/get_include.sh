#!/bin/bash
# Adds the include headers @ out directory

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

copyHeaders webrtc-checkout/src/third_party/abseil-cpp/absl out/include
copyHeaders webrtc-checkout/src/third_party/abseil-cpp/absl out/include
copyHeaders webrtc-checkout/src/api  out/include/webrtc
copyHeaders webrtc-checkout/src/base out/include/webrtc
copyHeaders webrtc-checkout/src/call out/include/webrtc
copyHeaders webrtc-checkout/src/common_video out/include/webrtc
copyHeaders webrtc-checkout/src/logging/rtc_event_log out/include/webrtc
copyHeaders webrtc-checkout/src/media out/include/webrtc
copyHeaders webrtc-checkout/src/modules out/include/webrtc
copyHeaders webrtc-checkout/src/p2p out/include/webrtc
copyHeaders webrtc-checkout/src/pc out/include/webrtc
copyHeaders webrtc-checkout/src/system_wrappers out/include/webrtc
copyHeaders webrtc-checkout/src/rtc_base out/include/webrtc
copyHeaders webrtc-checkout/src/third_party/jsoncpp/source/include/json out/include
copyHeaders webrtc-checkout/src/third_party/jsoncpp/generated/version.h out/include/json
copyHeaders webrtc-checkout/src/common_types.h out/include/webrtc
copyHeaders webrtc-checkout/src/third_party/ffmpeg/libavcodec/jni.h out/include/webrtc

#files other than *.h
mkdir -p  out/include/libc++
mkdir -p  out/include/libc++abi
cp -r webrtc-checkout/src/buildtools/third_party/libc++/trunk/include/* out/include/libc++
cp -r webrtc-checkout/src/buildtools/third_party/libc++abi/trunk/include/* out/include/libc++abi
#mkdir -p /external/include/build && cp webrtc-checkout/src/build/build_config.h "$_"
#cp webrtc-checkout/src/build/buildflag.h /external/include/build
