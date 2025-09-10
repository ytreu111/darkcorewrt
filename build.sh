#!/bin/bash

function init_repo() {
  git clone https://github.com/friendlyarm/repo --depth 1 tools
  tools/repo init -u https://github.com/friendlyarm/friendlywrt_manifests -b master-v24.10 \
      -m rk3328.xml --repo-url=https://github.com/friendlyarm/repo  --no-clone-bundle
  tools/repo sync -c  --no-clone-bundle
}

mkdir friendlywrt24-rk3328
cd friendlywrt24-rk3328

init_repo

source ../scripts/add_packages.sh

./build.sh rk3328.mk