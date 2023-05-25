#!/bin/bash
#v23

set -e

EVIO_REPO=https://github.com/EdgeVPNio/evio.git
EXT_REPO=https://github.com/EdgeVPNio/external.git
TOOLS_REPO=https://github.com/EdgeVPNio/tools.git
PORTAL_REPO=https://github.com/EdgeVPNio/portal.git
PY=python3.9
WorkspaceRoot=$(readlink -e ../..)

EVIO_DIR=$WorkspaceRoot/EdgeVPNio/evio/evio
TINCAN_DIR=$WorkspaceRoot/EdgeVPNio/tincan
EXT_DIR=$WorkspaceRoot/EdgeVPNio/external
TOOLS_DIR=$WorkspaceRoot/EdgeVPNio/tools
PORTAL_DIR=$WorkspaceRoot/EdgeVPNio/portal
OUT_DIR=$WorkspaceRoot/out
BuildWRTC=$TOOLS_DIR/scripts/build_webrtc.sh
GetArchives=$TOOLS_DIR/scripts/get_archives.sh
GetInclude=$TOOLS_DIR/scripts/get_include.sh
BuildTincan=$TOOLS_DIR/scripts/build_tincan.sh
Versioning=$TOOLS_DIR/versioning/versioning.py
VER=0
PLATFORM=""
BUILD_TYPE=""
ARCH=""
DATE="$(date '+%Y-%m-%d %T%z')"

function display_env
{
  echo DATE=$DATE
  echo VER=$VER
  echo PLATFORM=$PLATFORM
  echo BUILD_TYPE=$BUILD_TYPE
  echo ARCH=$ARCH
  echo WorkspaceRoot=$WorkspaceRoot
  echo OUT_DIR=$OUT_DIR
  echo EVIO_DIR=$EVIO_DIR
  echo EXT_DIR=$EXT_DIR
  echo TOOLS_DIR=$TOOLS_DIR
}

function check_env
{

    envlist="VER PLATFORM BUILD_TYPE ARCH"

    for env in $envlist
    do 
        echo ${!env}
        if [ -z ${!env} ]; then
            echo "Environment ${env} is not set, exiting."
            exit 1

        fi
    done
}

function update_repo
{
  rv=$(git -C $1 rev-parse --is-inside-work-tree)
  if [ "$rv" == "true" -o "$rv" == "false" ]; then
    git -C "$(dirname $1)" pull "$2"
  else
    git -C "$(dirname $1)" clone "$2"
  fi  
}

function sync_repos
{
  update_repo $EVIO_DIR $EVIO_REPO
  update_repo $EXT_DIR $EXT_REPO
  update_repo $TOOLS_DIR $TOOLS_REPO
  update_repo $PORTAL_DIR $PORTAL_REPO

}

function copy_evio_files
{
  echo target dir= "$1"
  cp -r $EVIO_DIR/evio_controller.py "$1"/ && \
  cp $EVIO_DIR/template-config.json "$1"/config.json && \
  cp -r $EVIO_DIR/broker/ $EVIO_DIR/controllers/ "$1"/ && \
  chmod 0775 "$1"/broker/ && \
  chmod 0664 "$1"/broker/* && \
  chmod 0775 "$1"/controllers/ && \
  chmod 0664 "$1"/controllers/* && \
  chmod 0664 "$1"/evio_controller.py && \
  chmod 0664 "$1"/config.json && \
  cp $TINCAN_DIR/out/"$PLATFORM"/"$BUILD_TYPE"/tincan "$1"/ && \
  chmod 0775 "$1"/tincan
}

function make_debpak
{
  display_env
  check_env

  sudo rm -rf $EVIO_DIR/controllers/__pycache__/ $EVIO_DIR/broker/__pycache__/
  wd=$(pwd)
  mkdir -p $TOOLS_DIR/debian-package/evio/etc/opt/evio
  # copy evio and tincan files to debpak directory
  cp -r $EVIO_DIR/evio_controller.py $TOOLS_DIR/debian-package/evio/opt/evio/ && \
  cp $EVIO_DIR/template-config.json $TOOLS_DIR/debian-package/evio/etc/opt/evio/config.json && \
  cp -r $EVIO_DIR/controllers/ $EVIO_DIR/broker/ $TOOLS_DIR/debian-package/evio/opt/evio/ && \
  chmod 0775 $TOOLS_DIR/debian-package/evio/opt/evio/broker/ && \
  chmod 0664 $TOOLS_DIR/debian-package/evio/opt/evio/broker/* && \
  chmod 0775 $TOOLS_DIR/debian-package/evio/opt/evio/controllers/ && \
  chmod 0664 $TOOLS_DIR/debian-package/evio/opt/evio/controllers/* && \
  chmod 0664 $TOOLS_DIR/debian-package/evio/opt/evio/evio_controller.py && \
  chmod 0664 $TOOLS_DIR/debian-package/evio/etc/opt/evio/config.json && \
  cp $TINCAN_DIR/out/"$PLATFORM"/"$BUILD_TYPE"/tincan $TOOLS_DIR/debian-package/evio/opt/evio/ && \
  chmod 0775 $TOOLS_DIR/debian-package/evio/opt/evio/tincan
  if [ $? -ne 0 ]; then
    exit 1
  fi
  mkdir -p $OUT_DIR
  # invoke deb-gen to create debian installer package
  cd $TOOLS_DIR/debian-package/ && \
    ./deb-gen $OUT_DIR $ARCH $VER $1
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # remove previously copied files
  sudo rm -rf evio/opt/evio/broker \
    evio/opt/evio/controllers \
    evio/opt/evio/tincan \
    evio/opt/evio/template-config.json \
    evio/opt/evio/evio_controller.py \
    evio/etc/opt/evio/config.json
  cd $wd
}

function install_testbed_deps
{
  sudo bash -c "
    apt-get update -y && \
    apt-get install -y openvswitch-switch \
                        $PY $PY-venv $PY-dev python3-pip \
                        apt-transport-https \
                        ca-certificates \
                        curl git \
                        software-properties-common && \

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable\" && \
    apt-cache policy docker-ce && \
    apt-get install -y containerd.io \
                       docker-ce-cli \
                       docker-ce && \
    groupadd -f docker && \
    usermod -a -G docker $USER && \
    newgrp docker \
  "
  exit
  groups | grep docker
  echo "If docker is not listed above, you must logout and relogin for docker group membership to take effect."
}

function make_dkrimg
{
  display_env
  check_env
  DPK_NAME=evio_$VER"_"$ARCH.deb
  echo Building evio node docker image using $DPK_NAME
  cp $OUT_DIR/$DPK_NAME $TOOLS_DIR/docker-image/evio"_"$ARCH.deb && \
  docker build --build-arg TARGETARCH="$ARCH" -f $TOOLS_DIR/docker-image/evio-node.Dockerfile -t edgevpnio/evio-node:"$VER" $TOOLS_DIR/docker-image
  rm $TOOLS_DIR/docker-image/evio"_"$ARCH.deb
}

function buildx_dkrimg
{
  display_env
  DPK_NAME_AMD=evio_$VER"_"amd64.deb
  DPK_NAME_ARM=evio_$VER"_"arm64.deb
  cp $OUT_DIR/$DPK_NAME_AMD $TOOLS_DIR/docker-image/evio"_"amd64.deb && \
  cp $OUT_DIR/$DPK_NAME_ARM $TOOLS_DIR/docker-image/evio"_"arm64.deb && \
  docker buildx use evibuilder && \
    docker buildx build --push \
        --build-arg VERSION="$VER" \
        --build-arg DATE="$DATE" \
        --platform linux/amd64,linux/arm64 \
        -f $TOOLS_DIR/docker-image/evio-node.Dockerfile \
        -t edgevpnio/evio-node:$VER \
        -t edgevpnio/evio-node:latest \
        $TOOLS_DIR/docker-image
  rm $TOOLS_DIR/docker-image/evio"_"amd64.deb $TOOLS_DIR/docker-image/evio"_"arm64.deb   
}

# function do_clean
# {
#   #TODO(ken): Unit test
#   # tincan
#   wd=$(pwd)

#   echo rm -ri $TINCAN_DIR/out
#   echo rm -ri $OUT_DIR
#   #debian pak
#   cd $TOOLS_DIR/debian-package/ && \
#   rm -ri ./*.deb \
#     evio/opt/evio/broker \
#     evio/opt/evio/controllers \
#     evio/opt/evio/tincan \
#     evio/opt/evio/template-config.json \
#     evio/opt/evio/evio_controller.py
#   # docker-image
#   cd ..
#   rm -f docker-image/*.deb
#   docker rmi edgevpnio/evio-node:"$VER"
#   docker rmi $(docker images -q --filter "dangling=true")
#   # testbed
#   cd $TOOLS_DIR/testbed
#   rm -rf config log cert venv
#   cd $wd
# }

function build_webrtc()
{
  display_env
  check_env
  wd=$(pwd)
  cd $WorkspaceRoot
  chmod +x $BuildWRTC $GetArchives $GetInclude
  $BuildWRTC -t $PLATFORM -b $BUILD_TYPE
  if [ $? -eq 0 ]; then
    cd $WorkspaceRoot
    $GetArchives -t $PLATFORM -b $BUILD_TYPE
    if [ $? -eq 0 ]; then
      cd $WorkspaceRoot
      $GetInclude
    fi
  fi
  cd $wd
}

function build_tincan {
  display_env
  check_env
  cd $WorkspaceRoot
  chmod +x $BuildTincan
  git -C "$EXT_DIR" checkout $PLATFORM
  $BuildTincan -t $PLATFORM -b $BUILD_TYPE
  if [ $? -ne 0 ]; then
    exit 1
  fi
}

function do_build
{
  build_tincan && \
  make_debpak && \
  make_dkrimg
}

function do_build_debian_x64_release
{
  $PY $Versioning --workspace_root=$WorkspaceRoot --gen_version_files
  VER=$($PY $Versioning --version)
  PLATFORM="debian-x64"
  BUILD_TYPE="release"
  ARCH="amd64"
  do_build
}

function do_build_debian_arm64_release
{
  $PY $Versioning --workspace_root=$WorkspaceRoot --gen_version_files
  VER=$($PY $Versioning --version)
  PLATFORM="debian-arm64"
  BUILD_TYPE="release"
  ARCH="arm64"
  do_build
}

function do_build_debian_arm_release
{
  $PY $Versioning --workspace_root=$WorkspaceRoot --gen_version_files
  VER=$($PY $Versioning --version)
  PLATFORM="debian-arm"
  BUILD_TYPE="release"
  ARCH="armhf"
  do_build
}

source venv/bin/activate
case $1 in
  sync)
    sync_repos
    ;;
  setup_testbed)
    install_testbed_deps
    ;;
  bldnum)
    if [ -z "$2" ]; then
        cat /var/tmp/evio_build_number
        echo ""
    elif [ "$2" == "set" ]; then
        if [ ! -z "$3" ]; then
            echo $2 > /var/tmp/evio_build_number
        else
            echo "No value for build number specified"
        fi
    elif [ "$2" == "next" ]; then
        $PY $Versioning --next_build_num
        $PY $Versioning --workspace_root=$WorkspaceRoot --gen_version_files -verbose
    fi
    ;;
  build)
    VER=$($PY $Versioning --version)
    $PY $Versioning --workspace_root=$WorkspaceRoot --gen_version_files -verbose
    if [ "$3" == "amd64" ]; then
        PLATFORM="debian-x64"
        ARCH="amd64"
    elif [ "$3" == "arm64" ]; then
        PLATFORM="debian-arm64"
        ARCH="arm64"
    elif [ "$3" == "arm" ]; then
        PLATFORM="debian-arm"
        ARCH="armhf"
    fi
    if [ "$4" == "rel" ]; then
        BUILD_TYPE="release"
    elif [ "$4" == "dbg" ]; then
        BUILD_TYPE="debug"
    fi
    if [ "$2" == "debpak" ]; then
        make_debpak $5
    elif [ "$2" == "dkrimg" ]; then
        make_dkrimg
    elif [ "$2" == "webrtc" ]; then
        build_webrtc
    elif [ "$2" == "tincan" ]; then
        build_tincan
    fi
    ;;
  buildx)
    VER=$($PY $Versioning --version)
    $PY $Versioning --workspace_root=$WorkspaceRoot --gen_version_files
    BUILD_TYPE="release"
    buildx_dkrimg
    ;;
  build_debx64_rel)
    do_build_debian_x64_release
    ;;
  build_debarm64_rel)
    do_build_debian_arm64_release
    ;;
  build_debarm_rel)
    do_build_debian_arm_release
    ;;
  fbr)
    $PY $Versioning --next_build_num
    $PY $Versioning --workspace_root=$WorkspaceRoot --gen_version_files -verbose
    VER=$($PY $Versioning --version)
    PLATFORM="debian-x64"
    ARCH="amd64"
    BUILD_TYPE="release"
    make_debpak
    sudo apt install -y "$OUT_DIR"/evio_"$VER"_"$ARCH".deb
    ;;
  *)
    echo "no match on input -> $1"
    ;;
esac
