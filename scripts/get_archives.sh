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

mkdir -p out/$platform/external/libs
#getting the required .o files and .a files to 3rd party libs from webrtc-checkout
Workspace_root=`pwd`
LLVM-AR=$Workspace_root/EdgeVPNIO/tools/llvm/bin/llvm-ar
LLVM-AR -rcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/rtc_base/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/rtc_base_approved/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/p2p/rtc_p2p/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/logging/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/rtc_event/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/stringutils/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/timeutils/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/platform_thread_types/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/criticalsection/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/crypto/options/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/pc/rtc_pc_base/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/checks/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/synchronization/sequence_checker/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/synchronization/yield_policy/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/rtc_error/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/system_wrappers/metrics/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/system_wrappers/field_trial/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/logging/ice_log/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/experiments/field_trial_parser/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/transport/stun_types/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/libjingle_peerconnection_api/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/weak_ptr/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/network/sent_packet/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/rtc_numerics/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/third_party/base64/base64/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/task_queue/task_queue/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/system/file_wrapper/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/rtc_base/platform_thread/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/rtc_event_log/rtc_event_log/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/rtp_parameters/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/transport/media/media_transport_interface/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/call/rtp_receiver/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/modules/rtp_rtcp/rtp_rtcp_format/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/media/rtc_media_base/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/units/data_size/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/units/time_delta/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/units/data_rate/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/api/video/video_rtp_headers/*.o
LLVM-AR -qcs out/$platform/external/libs/libwebrtc_lite.a webrtc-checkout/src/out/$build_type/obj/pc/media_protocol_names/*.o
#archives from third-party directory
LLVM-AR -rcs out/$platform/external/libs/libboringssl_asm.a webrtc-checkout/src/out/$build_type/obj/third_party/boringssl/boringssl_asm/*.o
LLVM-AR -qcs out/$platform/external/libs/libjsoncxx.a webrtc-checkout/src/out/$build_type/obj/third_party/jsoncpp/jsoncpp/json_reader.o webrtc-checkout/src/out/$build_type/obj/third_party/jsoncpp/jsoncpp/json_value.o webrtc-checkout/src/out/$build_type/obj/third_party/jsoncpp/jsoncpp/json_writer.o
LLVM-AR -rcs out/$platform/external/libs/libboringssl.a webrtc-checkout/src/out/$build_type/obj/third_party/boringssl/boringssl/*.o
LLVM-AR -rcs out/$platform/external/libs/libprotobuf_lite.a webrtc-checkout/src/out/$build_type/obj/third_party/protobuf/protobuf_lite/*.o
LLVM-AR -qcs out/$platform/external/libs/libabseil_cpp.a webrtc-checkout/src/out/$build_type/obj/third_party/abseil-cpp/absl/strings/strings/*.o  webrtc-checkout/src/out/$build_type/obj/third_party/abseil-cpp/absl/base/throw_delegate/*.o webrtc-checkout/src/out/$build_type/obj/third_party/abseil-cpp/absl/types/bad_optional_access/*.o webrtc-checkout/src/out/$build_type/obj/third_party/abseil-cpp/absl/base/raw_logging_internal/*.o
LLVM-AR -rcs out/$platform/external/libs/libsrtp.a webrtc-checkout/src/out/$build_type/obj/third_party/libsrtp/libsrtp/*.o
LLVM-AR -rcs out/$platform/external/libs/libc++.a webrtc-checkout/src/out/$build_type/obj/buildtools/third_party/libc++/libc++/*.o
LLVM-AR -rcs out/$platform/external/libs/libc++abi.a webrtc-checkout/src/out/$build_type/obj/buildtools/third_party/libc++abi/libc++abi/*.o
