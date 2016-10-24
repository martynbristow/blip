#!/bin/bash
#
# MIT License
#
# Copyright (c) 2016 Nicola Worthington
#
# Temporary script while I'm still learning about Debian packaging best
# practices and the like. This script isn't really intended for general
# consumption. I intend to automate the creation of release tarballs
# and packages so that you don't have to do this kind of stuff.
#
# https://nicolaw.uk/DebianPackaging
# http://www.rpm.org/max-rpm/s1-rpm-pgp-signing-packages.html

set -vxueo pipefail
umask 0077

main () {
    declare base
    base="$(readlink -f "$(dirname "$0")")"
    declare -x pkg="blip"

    [[ -e "$base/${pkg}.bash" ]]
    source "$base/${pkg}.bash"

    # Version information for releases spewed in a couple of different
    # places for Debs and RPMs, so this argument is mostly meaningless
    # at the moment. It needs to be tied in to git release tags anyway.
    declare dch_version_full
    dch_version_full="$(egrep -o "^${pkg} \([0-9]+\.[0-9]+(-[0-9]+)?\) " "$base/debian/changelog" | egrep -o '[0-9]+\.[0-9]+(-[0-9]+)?' | head -1)"
    declare -x dch_version="${dch_version_full%-*}"
    declare -x dch_release="${dch_version_full#*-}"
    declare -x version="${1:-$dch_version}"
    declare -x release="${2:-$dch_release}"
    release="${release:-1}"

    [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]
    is_int "$release"

    declare -x build_base="$base/build"
    declare -x build_dir="$build_base/${pkg}-${version}"
    declare -x release_dir="$base/release/${pkg}-${version}${release:+-$release}"

    # We should sign stuff if we're the author.
    declare rpmbuild_extra_args
    declare debuild_extra_args
    declare gpg_keyid
    if [[ "$(hostid)" = "007f0101" ]] && [[ "$(get_username)" = "nicolaw" ]] ; then
        gpg_keyid="6393F646"
        debuild_extra_args="-k${gpg_keyid}"
        rpmbuild_extra_args="--sign"
        while read -r line ; do
            if ! grep -q "^$line$" ~/.rpmmacros ; then
                echo "$line" >> ~/.rpmmacros
            fi
        done <<RPMMACROS
%_signature gpg
%_gpg_name $(get_gecos_name)
%_gpgbin /usr/bin/gpg
RPMMACROS
    fi

    # Generate some Groff man pages from the POD source.
    pod2man \
        --name="BLIP.BASH" \
        --release="${pkg}.bash $version" \
        --center="${pkg}.bash" \
        --section=3 \
        --utf8 "$base/${pkg}.bash.pod" > "$base/${pkg}.bash.3"

    if is_in_path "markdown" ; then
        markdown "$base/README.md"
    else
        echo "Missing 'markdown' package is required to build README.html from README.md."
    fi > "$base/README.html"

    # Scan for missing documentation.
    declare -x missing_func_docs=""
    while read -r function ; do
        function="${function%% *}"
        if ! grep -q "^=head2 $function " "$base/${pkg}.bash.pod" ; then
            missing_func_docs="${missing_func_docs:+$missing_func_docs }${function%% *}"
        fi
    done < <(egrep -o '^[a-z_]+\ \(\)' "$base/${pkg}.bash" | sort -u)

    # Build tarball.
    rm -Rf --one-file-system --preserve-root "$build_base"
    mkdir -p "$build_dir" "$release_dir"
    rsync -av --exclude=".*" --exclude="build/" --exclude="release/" "${base%/}/" "${build_dir%}/"
    tar -C "$build_base" -zcvf "$build_base/${pkg}-${version}.tar.gz" "$(basename "$build_dir")"
    cp -v "$build_base/${pkg}-${version}.tar.gz" "$release_dir"

    # Build Deb package.
    if is_in_path "debuild" "dpkg-deb" ; then
        cp -v "$build_base/${pkg}-${version}.tar.gz" "$build_base/${pkg}_${version}.orig.tar.gz"
        pushd "$build_dir"
        debuild -sa ${debuild_extra_args:- -us -uc}
        popd
        pushd "$build_base"
        #if [[ -n "$gpg_keyid" ]] ; then
        #    for file in "$build_base"/*.dsc "$build_base"/*.changes ; do
        #        debsign -k "$gpg_keyid" "$file"
        #        gpg --verify "$file"
        #    done
        #fi
        mv -v -- *.dsc *.changes *.build *.debian.tar.gz *.orig.tar.gz *.deb "$release_dir"
        dpkg-deb -I "$release_dir/${pkg}_${version}${release:+-$release}_all.deb"
        dpkg-deb -c "$release_dir/${pkg}_${version}${release:+-$release}_all.deb"
        popd
    fi

    # Build RPM package.
    if is_in_path "rpmbuild" "rpm" ; then
        rpmbuild -ba "${pkg}.spec" \
            ${rpmbuild_extra_args} \
            ${pkg:+--define "name $pkg"} \
            ${version:+--define "version $version"} \
            ${release:+--define "release $release"} \
            --define "_sourcedir $build_base" \
            --define "_rpmdir $release_dir" \
            --define "_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm"
        rpm -qlpiv "$release_dir/${pkg}-${version}${release:+-$release}.noarch.rpm"
    fi

    # Print a summary of any functions that need to be added to documentation.
    if [[ -n "$missing_func_docs" ]] ; then
        echo -e "\e[0;1;33mMissing function documentation:\e[0m $missing_func_docs"
    fi

    # List the resulting release package files.
    ls --color -la "$release_dir"
}

main "$@"

