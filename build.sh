#!/bin/bash

WRT_DIR=friendlywrt24-rk3328
SETUP_SCRIPT_PATH="friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh"
DEBUG=false

for arg in "$@"
do
    case $arg in
        --debug)
        DEBUG=true
        shift
        ;;
        *)
        ;;
    esac
done


function init_repo() {
  git clone https://github.com/friendlyarm/repo --depth 1 tools
  tools/repo init -u https://github.com/friendlyarm/friendlywrt_manifests -b master-v24.10 \
      -m rk3328.xml --repo-url=https://github.com/friendlyarm/repo  --no-clone-bundle
  tools/repo sync -c  --no-clone-bundle
}

function add_scripts(){
  echo "0 0 * * * curl -fsSL \"https://raw.githubusercontent.com/special-router/darkcore-updater/main/update.sh\" | sh" >> ${BUILD_ROOT_DIR}/etc/crontabs/root
  echo "15 0 * * * geoupdate" >> ${BUILD_ROOT_DIR}/etc/crontabs/root
  echo "*/5 * * * * dcvpnupd" >> ${BUILD_ROOT_DIR}/etc/crontabs/root
}

function setup_initial_script {
  sed -i -e 's|HOSTNAME="FriendlyWrt"|HOSTNAME="DarkCore"|g' "${SETUP_SCRIPT_PATH}"
  sed -i -e 's|zonename=Asia\/Shanghai|zonename=UTC|g' "${SETUP_SCRIPT_PATH}"

  if [ "$DEBUG" = true ]; then
    sed -i -e "s|firewall\.@zone\[1\]\.input='REJECT'|firewall.@zone[1].input='ACCEPT'|g" "${SETUP_SCRIPT_PATH}"
    sed -i -e "s|firewall\.@zone\[1\]\.forward='REJECT'|firewall.@zone[1].forward='ACCEPT'|g" "${SETUP_SCRIPT_PATH}"
  fi
}

mkdir ${WRT_DIR}
cd ${WRT_DIR}

init_repo

source ../scripts/add_packages.sh
setup_initial_script

MK_LINK=".current_config.mk"
FOUND_MK_FILE=`find device/friendlyelec -name rk3328.mk | wc -l`

if [ $FOUND_MK_FILE -gt 0 ]; then
  MK_FILE=`ls device/friendlyelec/*/rk3328.mk`
  echo "using config ${MK_FILE}"
  rm -f ${MK_LINK}
  ln -s ${MK_FILE} ${MK_LINK}
  source ${MK_LINK}

  ./build.sh uboot
  ./build.sh kernel
  ./build.sh friendlywrt

  BUILD_ROOT_DIR="$(pwd)/${FRIENDLYWRT_SRC}/${FRIENDLYWRT_ROOTFS}"
  XRAY_SHARE_DIR="${BUILD_ROOT_DIR}/usr/share/xray"

  mkdir -p "${XRAY_SHARE_DIR}"
  wget -O "${XRAY_SHARE_DIR}/geoip.dat" https://raw.githubusercontent.com/runetfreedom/russia-v2ray-rules-dat/release/geoip.dat
  wget -O "${XRAY_SHARE_DIR}/geosite.dat" https://raw.githubusercontent.com/runetfreedom/russia-v2ray-rules-dat/release/geosite.dat

  add_scripts

  # hBZEELh2rn
  if [ "$DEBUG" = false ]; then
    sed -i 's/root:.*:0/root:$5$AihGSVJEaob0lc\/t$nvkHtsTi4zagDxnsyGufaa94e6v11Kjlo16q0NuGto.:20382:0/' "${BUILD_ROOT_DIR}/etc/shadow"
  fi

  ./build.sh sd-img
else
  echo "no config rk3328 in device/friendlyelec"
  exit 1
fi
