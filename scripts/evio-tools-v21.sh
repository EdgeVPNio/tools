#!/bin/bash
#v21
EVIO_REPO=https://github.com/EdgeVPNio/evio.git
EXT_REPO=https://github.com/EdgeVPNio/external.git
TOOLS_REPO=https://github.com/EdgeVPNio/tools.git
PORTAL_REPO=https://github.com/EdgeVPNio/portal.git
PY=python3.8
WorkspaceRoot=$(readlink -e ../..)

EVIO_DIR=$WorkspaceRoot/EdgeVPNio/evio
EXT_DIR=$WorkspaceRoot/EdgeVPNio/external
TOOLS_DIR=$WorkspaceRoot/EdgeVPNio/tools
PORTAL_DIR=$WorkspaceRoot/EdgeVPNio/portal
OUT_DIR=$WorkspaceRoot/out
BuildWRTC=$TOOLS_DIR/scripts/build_webrtc.sh
GetArchives=$TOOLS_DIR/scripts/get_archives.sh
GetInclude=$TOOLS_DIR/scripts/get_include.sh
BuildTincan=$TOOLS_DIR/scripts/build_tincan.sh
VER=0
PLATFORM=""
BUILD_TYPE=""
ARCH=""

function display_env
{
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

function make_debpak
{
  wd=$(pwd)
  mkdir -p $TOOLS_DIR/debian-package/evio/etc/opt/evio
  # copy controller and tincan files to debpak directory
  cp -r $WorkspaceRoot/EdgeVPNio/evio/controller/Controller.py $TOOLS_DIR/debian-package/evio/opt/evio/ && \
  cp $WorkspaceRoot/EdgeVPNio/evio/controller/template-config.json $TOOLS_DIR/debian-package/evio/etc/opt/evio/config.json && \
  cp -r $WorkspaceRoot/EdgeVPNio/evio/controller/modules/ $WorkspaceRoot/EdgeVPNio/evio/controller/framework/ $TOOLS_DIR/debian-package/evio/opt/evio/ && \
  chmod 0775 $TOOLS_DIR/debian-package/evio/opt/evio/framework/ && \
  chmod 0664 $TOOLS_DIR/debian-package/evio/opt/evio/framework/* && \
  chmod 0775 $TOOLS_DIR/debian-package/evio/opt/evio/modules/ && \
  chmod 0664 $TOOLS_DIR/debian-package/evio/opt/evio/modules/* && \
  chmod 0664 $TOOLS_DIR/debian-package/evio/opt/evio/Controller.py && \
  chmod 0664 $TOOLS_DIR/debian-package/evio/etc/opt/evio/config.json && \
  cp $EVIO_DIR/tincan/out/"$PLATFORM"/"$BUILD_TYPE"/tincan $TOOLS_DIR/debian-package/evio/opt/evio/ && \
  chmod 0775 $TOOLS_DIR/debian-package/evio/opt/evio/tincan
  if [ $? -ne 0 ]; then
    exit 1
  fi
  mkdir -p $OUT_DIR
  # invoke deb-gen to create debian installer package
  cd $TOOLS_DIR/debian-package/ && \
    ./deb-gen $OUT_DIR $ARCH $VER
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # remove previously copied files
  rm -rf evio/opt/evio/framework \
    evio/opt/evio/modules \
    evio/opt/evio/tincan \
    evio/opt/evio/template-config.json \
    evio/opt/evio/Controller.py \
    evio/etc/opt/evio/config.json
  cd $wd
}

function upload_debpak
{
  #TODO: complete package naming
  curl -F package=@evio_21.4.0.99-dev_amd64.deb https://1b28QB-kHDzLyq2QY8vDWCbO7JgecMvi8@push.fury.io/evio/
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
  groups | grep docker
  echo "If docker is not listed above, you must logout and relogin for docker group membership to take effect."
}

function make_dkrimg
{
  display_env
  DPK_NAME=evio_$VER"_"$ARCH.deb
  echo docker image using $DPK_NAME
  cp $OUT_DIR/$DPK_NAME $TOOLS_DIR/docker-image/evio.deb && \
  docker build -f $TOOLS_DIR/docker-image/evio-base.Dockerfile -t edgevpnio/evio-base:1.1 $TOOLS_DIR/docker-image && \
  docker build -f $TOOLS_DIR/docker-image/evio-node.Dockerfile -t edgevpnio/evio-node:"$VER" $TOOLS_DIR/docker-image
  rm $TOOLS_DIR/docker-image/evio.deb
}

function install_openfire
{
  docker run --name openfire -d \
    -p 9090:9090 -p 5222:5222 \
    -p 5269:5269 -p 5223:5223 \
    -p 7443:7443 -p 7777:7777 \
    -p 7070:7070 -p 5229:5229 \
    -p 5275:5275 \
    edgevpnio/openfire_edgevpn_demo
}

function install_portal
{
  #TODO(ken): visualizer not yet available
  cd $WorkspaceRoot/EdgeVPNio
  git clone $PORTAL_REPO
  cd portal/setup
  ./setup.sh
  chown -R $USER /users/$USER/
}

function do_clean
{
  #TODO(ken): Unit test
  # tincan
  wd=$(pwd)

  echo rm -ri $EVIO_DIR/tincan/out
  echo rm -ri $OUT_DIR
  #debian pak
  cd $TOOLS_DIR/debian-package/ && \
  rm -ri ./*.deb \
    evio/opt/evio/framework \
    evio/opt/evio/modules \
    evio/opt/evio/tincan \
    evio/opt/evio/template-config.json \
    evio/opt/evio/Controller.py
  # docker-image
  cd ..
  rm -f docker-image/*.deb
  docker rmi edgevpnio/evio-base:1.0 edgevpnio/evio-node:20.7
  docker rmi $(docker images -q --filter "dangling=true")
  # testbed
  cd $TOOLS_DIR/testbed
  rm -rf config log cert venv
  cd $wd
}

function build_webrtc()
{
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

function do_build_debian_x64_debug
{
  $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
  VER=$($PY ./scripts/Versioning.py --version)
  PLATFORM="debian-x64"
  BUILD_TYPE="debug"
  ARCH="amd64"
  do_build
}

function do_build_debian_x64_release
{
  $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
  VER=$($PY ./scripts/Versioning.py --version)
  PLATFORM="debian-x64"
  BUILD_TYPE="release"
  ARCH="amd64"
  do_build
}

function do_build_debian_arm_debug
{
  $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
  VER=$($PY ./scripts/Versioning.py --version)
  PLATFORM="debian-arm"
  BUILD_TYPE="debug"
  ARCH="armhf"
  do_build
}

function do_build_debian_arm_release
{
  $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
  VER=$($PY ./scripts/Versioning.py --version)
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
  xmpp)
    install_openfire
    ;;
  clean)
    echo do_clean
    ;;
  next_bld_num)
    $PY ./scripts/Versioning.py --next_build_num
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    ;;    
  debpak_x64_dbg)
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-x64"
    BUILD_TYPE="debug"
    ARCH="amd64"  
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    make_debpak
      ;;
  debpak_x64_rel)
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-x64"
    BUILD_TYPE="release"
    ARCH="amd64"   
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    make_debpak
      ;;
  debpak_arm_dbg)
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-arm"
    BUILD_TYPE="debug"
    ARCH="armhf"
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    make_debpak
      ;;
  debpak_arm_rel)
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-arm"
    BUILD_TYPE="release"
    ARCH="armhf"
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    make_debpak
    ;;
  debpak_arm64_dbg)
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-arm64"
    BUILD_TYPE="debug"
    ARCH="arm64"
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    make_debpak
      ;;
  debpak_arm64_rel)
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-arm64"
    BUILD_TYPE="release"
    ARCH="arm64"
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    make_debpak
    ;;    
  dkrimg_x64)
    VER=$($PY ./scripts/Versioning.py --version)
    ARCH="amd64"
    make_dkrimg
    ;;
  dkrimg_arm)
    VER=$($PY ./scripts/Versioning.py --version)
    ARCH="armhf"
    make_dkrimg
    ;;
  build_webrtc_dx64_dbg)
    PLATFORM="debian-x64"
    BUILD_TYPE="debug"
    build_webrtc
    ;;
  build_webrtc_dx64_rel)
    PLATFORM="debian-x64"
    BUILD_TYPE="release"
    build_webrtc
    ;;
  build_webrtc_darm_dbg)
    PLATFORM="debian-arm"
    BUILD_TYPE="debug"
    build_webrtc
    ;;
  build_webrtc_darm_rel)
    PLATFORM="debian-arm"
    BUILD_TYPE="release"
    build_webrtc
    ;;
  build_tincan_dx64_dbg)
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-x64"
    BUILD_TYPE="debug"    
    build_tincan
    ;;
  build_tincan_dx64_rel)
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-x64"
    BUILD_TYPE="release"     
    build_tincan
    ;;
  build_tincan_dx86_rel)
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-x86"
    BUILD_TYPE="release"     
    build_tincan
    ;;
  build_tincan_darm_dbg)
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-arm"
    BUILD_TYPE="debug"
    build_tincan
    ;;
  build_tincan_darm_rel)
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-arm"
    BUILD_TYPE="release"
    build_tincan
    ;;
  build_tincan_darm64_rel)
    $PY ./scripts/Versioning.py --workspace_root=$WorkspaceRoot --gen_version_files
    VER=$($PY ./scripts/Versioning.py --version)
    PLATFORM="debian-arm64"
    BUILD_TYPE="release"
    build_tincan
    ;;
  build_dx64_dbg)
    do_build_debian_x64_debug
    ;;
  build_dx64_rel)
    do_build_debian_x64_release
    ;;
  build_darm_dbg)
    do_build_debian_arm_debug
    ;;
  build_darm_rel)
    do_build_debian_arm_release
    ;;
  *)
    echo "no match on input -> $1"
    ;;
esac
