#!/bin/bash

set -e

# Make a copy so we never alter the original
cp -r /pkg /tmp/pkg
cd /tmp/pkg

# Install (official repo + AUR) dependencies using paru. We avoid using
# `makepkg -s` since it is unable to install AUR dependencies.
depends=(); makedepends=(); checkdepends=()
# shellcheck disable=1091
. ./PKGBUILD
deps=( "${depends[@]}" "${makedepends[@]}" "${checkdepends[@]}" )
pacman --deptest "${deps[@]}" | xargs paru -Sy --noconfirm

# Do the actual building
makepkg -f

# Store the built package(s). Ensure permissions match the original PKGBUILD.
if [ -n "$EXPORT_PKG" ]; then
    sudo chown "$(stat -c '%u:%g' /pkg/PKGBUILD)" ./*pkg.tar*
    sudo mv ./*pkg.tar* /pkg
fi
# Export .SRCINFO for built package
if [ -n "$EXPORT_SRC" ]; then
    makepkg --printsrcinfo > .SRCINFO
    sudo chown "$(stat -c '%u:%g' /pkg/PKGBUILD)" ./.SRCINFO
    sudo mv ./.SRCINFO /pkg
fi
