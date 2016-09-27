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

    pod2man \
        --name="BLIP" \
        --release="blip.bash $version" \
        --center="blip.bash" \
        --section=3 \
        --utf8 "$base/blip.pod" > "$base/blip.3"

    # Scan for missing documentation.
    local missing_func_docs=""
    while read function ; do
        function="${function#* }"
        if ! grep -q "^=head2 $function$" "$base/blip.pod" ; then
            missing_func_docs="${missing_func_docs:+$missing_func_docs }${function%% *}"
        fi
    done < <(egrep -o '=head2 ^[a-z_]+\ \(\)' "$base/blip.bash" | sort -u)

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

    if [[ -n "$missing_func_docs" ]] ; then
        echo -e "\e[0;1;33mMissing function documentation:\e[0m $missing_func_docs"
    fi

    ls --color -la "$base"/*.deb "$base"/*.rpm "$base"/*.gz
}

main "$@"

