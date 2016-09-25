#!/bin/bash

# Temporary script while I'm still learning about Debian packaging best
# practices and the like. This script isn't really intended for general
# consumption. I intend to automate the creation of release tarballs
# and packages so that you don't have to do this kind of stuff.
#
# https://nicolaw.uk/DebianPackaging

set -euxo pipefail

main () {
    # Version information for releases spewed in a couple of different
    # places for Debs and RPMs, so this argument is mostly meaningless
    # at the moment. It needs to be tied in to git release tags anyway.
    local version="${1:-0.01}"
    local release="${2:-1}"

    local base="$(readlink -f "$(dirname "$0")")"
    [[ -e "$base/blip.bash" ]]
    source "$base/blip.bash"

    local build_dir="$base/blip-${version}/"

    rm -Rf --one-file-system --preserve-root "$build_dir" \
        *.deb *.changes *.dsc *.build *.gz *.rpm

    # Build tarball.
    mkdir -p "$build_dir"
    rsync -av --files-from="$base/MANIFEST" "$base" "$build_dir"
    tar -C "$base" -zcvf "$base/blip-${version}.tar.gz" "$(basename "$build_dir")"

    # Build Deb package.
    if is_in_path "debuild" "dpkg-deb" ; then
        ln -s "$base/blip-${version}.tar.gz" "$base/blip_${version}.orig.tar.gz"
        pushd "$build_dir"
        debuild -us -uc
        popd
        dpkg-deb -I "blip_${version}_all.deb"
        dpkg-deb -c "blip_${version}_all.deb"
    fi

    # Build RPM package.
    if is_in_path "rpmbuild" "rpm" ; then
        rpmbuild -ba blip.spec \
            ${version:+--define "version $version"} \
            ${release:+--define "release $release"} \
            --define "_sourcedir $base" \
            --define "_rpmdir $base" \
            --define "_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm"
        rpm -qlpiv "$base/blip-${version}-${release}.noarch.rpm"
    fi
}

main "$@"

