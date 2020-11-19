#!/bin/bash

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
                ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
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

mkdir -p out/libs/$target/$build_type
#getting the required .o files and .a files to 3rd party libs from webrtc-checkout
Workspace_root=`pwd`
LLVM=$Workspace_root/EdgeVPNio/tools/llvm/bin/llvm-ar
$LLVM -rcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/rtc_base/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/rtc_base_approved/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/p2p/rtc_p2p/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/logging/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/rtc_event/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/stringutils/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/timeutils/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/platform_thread_types/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/criticalsection/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/crypto/options/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/pc/rtc_pc_base/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/checks/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/synchronization/sequence_checker/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/synchronization/yield_policy/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/rtc_error/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/system_wrappers/metrics/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/system_wrappers/field_trial/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/logging/ice_log/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/experiments/field_trial_parser/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/transport/stun_types/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/libjingle_peerconnection_api/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/weak_ptr/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/network/sent_packet/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/rtc_numerics/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/third_party/base64/base64/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/task_queue/task_queue/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/system/file_wrapper/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/rtc_base/platform_thread/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/rtc_event_log/rtc_event_log/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/rtp_parameters/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/transport/media/media_transport_interface/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/call/rtp_receiver/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/modules/rtp_rtcp/rtp_rtcp_format/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/media/rtc_media_base/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/units/data_size/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/units/time_delta/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/units/data_rate/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/api/video/video_rtp_headers/*.o
$LLVM -qcs out/libs/$target/$build_type/libwebrtc_lite.a webrtc-checkout/src/out/$target/$build_type/obj/pc/media_protocol_names/*.o
#archives from third-party directory
$LLVM -rcs out/libs/$target/$build_type/libboringssl_asm.a webrtc-checkout/src/out/$target/$build_type/obj/third_party/boringssl/boringssl_asm/*.o
$LLVM -qcs out/libs/$target/$build_type/libjsoncxx.a webrtc-checkout/src/out/$target/$build_type/obj/third_party/jsoncpp/jsoncpp/json_reader.o webrtc-checkout/src/out/$target/$build_type/obj/third_party/jsoncpp/jsoncpp/json_value.o webrtc-checkout/src/out/$target/$build_type/obj/third_party/jsoncpp/jsoncpp/json_writer.o
$LLVM -rcs out/libs/$target/$build_type/libboringssl.a webrtc-checkout/src/out/$target/$build_type/obj/third_party/boringssl/boringssl/*.o
$LLVM -rcs out/libs/$target/$build_type/libprotobuf_lite.a webrtc-checkout/src/out/$target/$build_type/obj/third_party/protobuf/protobuf_lite/*.o
$LLVM -qcs out/libs/$target/$build_type/libabseil_cpp.a webrtc-checkout/src/out/$target/$build_type/obj/third_party/abseil-cpp/absl/strings/strings/*.o  webrtc-checkout/src/out/$target/$build_type/obj/third_party/abseil-cpp/absl/base/throw_delegate/*.o webrtc-checkout/src/out/$target/$build_type/obj/third_party/abseil-cpp/absl/types/bad_optional_access/*.o webrtc-checkout/src/out/$target/$build_type/obj/third_party/abseil-cpp/absl/base/raw_logging_internal/*.o
$LLVM -rcs out/libs/$target/$build_type/libsrtp.a webrtc-checkout/src/out/$target/$build_type/obj/third_party/libsrtp/libsrtp/*.o
$LLVM -rcs out/libs/$target/$build_type/libc++.a webrtc-checkout/src/out/$target/$build_type/obj/buildtools/third_party/libc++/libc++/*.o
$LLVM -rcs out/libs/$target/$build_type/libc++abi.a webrtc-checkout/src/out/$target/$build_type/obj/buildtools/third_party/libc++abi/libc++abi/*.o
