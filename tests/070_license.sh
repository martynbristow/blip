#!/bin/bash

test_070_license () {
    declare -x base="${BASH_SOURCE[0]%/*}/../"
    declare -ax strings=(
            "MIT License"
            "Copyright (c) 2016 Nicola Worthington"
            )
    for file in blip.bash LICENSE debian/copyright build.sh Makefile
    do
        for string in "${strings[@]}"
        do
            assert_raises "grep -w '$string' '${base%/}/$file'" 0 ""
        done
    done

    assert_end "${BASH_SOURCE[0]##*/}"
}

