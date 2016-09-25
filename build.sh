#!/bin/bash

# Temporary script while I'm still learning about Debian packaging best
# practices and the like.
#
# https://nicolaw.uk/DebianPackaging

set -euxo pipefail

main () {
    local base="$(dirname "$0")"
    [[ -e "$base/blip.bash" ]]

    local version="0.01"
    local build_dir="$base/blip-${version}/"

    rm -Rf --one-file-system --preserve-root "$build_dir"
    mkdir -p "$build_dir"
    rsync -av --files-from="$base/MANIFEST" "$base" "$build_dir"
    tar -C "$base" -Jcvf "$base/blip-${version}.tar.xz" "$(basename "$build_dir")"
    cp "$base/blip-${version}.tar.xz" "$base/blip_${version}.orig.tar.xz"

    pushd "$build_dir"
    debuild -us -uc
    popd

    local deb="$base/blip_${version}_all.deb"
    [[ -e "$deb" ]] && sudo dpkg -i "$deb"
}

main "$@"

