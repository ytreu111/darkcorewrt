#!/bin/bash

# {{ Add luci-app-diskman
(cd friendlywrt && {
    mkdir -p package/luci-app-diskman
    wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile.old -O package/luci-app-diskman/Makefile
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
CONFIG_PACKAGE_smartmontools=y
EOL
# }}


# {{ Add DarkCore packages
(cd friendlywrt/package && {
    [ -d darkcore ] && rm -rf darkcore
    git clone https://github.com/special-router/darkcore-packages.git darkcore --depth 1 -b main
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_darkcore-xray=y
CONFIG_PACKAGE_darkcore-main=y
CONFIG_PACKAGE_geoupdate=y
CONFIG_PACKAGE_dcvpnupd=y
EOL
# }}
