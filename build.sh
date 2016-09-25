#!/bin/bash

# Temporary script while I'm still learning about Debian packaging best
# practices and the like. This script isn't really intended for general
# consumption. I intend to automate the creation of release tarballs
# and packages so that you don't have to do this kind of stuff.
#
# https://nicolaw.uk/DebianPackaging

set -euxo pipefail

main () {
    local base="$(readlink -f "$(dirname "$0")")"
    [[ -e "$base/blip.bash" ]]

    local version="0.01"
    local build_dir="$base/blip-${version}/"

    rm -Rf --one-file-system --preserve-root "$build_dir" \
        *.deb *.changes *.dsc *.build *.gz *.rpm

    mkdir -p "$build_dir"
    rsync -av --files-from="$base/MANIFEST" "$base" "$build_dir"
    tar -C "$base" -zcvf "$base/blip-${version}.tar.gz" "$(basename "$build_dir")"
    cp "$base/blip-${version}.tar.gz" "$base/blip_${version}.orig.tar.gz"

    pushd "$build_dir"
    debuild -us -uc
    popd

    local deb="$base/blip_${version}_all.deb"
    [[ -e "$deb" ]] && sudo dpkg -i "$deb"

    rpmbuild -ba blip.spec \
        --define "_sourcedir $base" \
        --define "_rpmdir $base" \
        --define "_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm"
}

main "$@"

