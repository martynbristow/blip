#!/bin/bash

set -euo pipefail

. "${BASH_SOURCE[0]%/*}/assert.sh"
. "${BASH_SOURCE[0]%/*}/_clear_blip.sh"

tests () {
    declare -x blip="${BASH_SOURCE[0]%/*}/../blip.bash"
    _clear_blip

    # Try loading blip.
    assert_raises "bash -c '_clear_blip; . \"$blip\"'" 0 ""

    # Require a newer version of blip.
    assert_raises "bash -c '_clear_blip; BLIP_REQUIRE_VERSION=999.999-999; . \"$blip\"'" 2 ""
    assert "bash -c '_clear_blip; BLIP_REQUIRE_VERSION=999.999-999; . \"$blip\"' 2>&1" \
        "blip.bash version 0.1-4-prerelease does not satisfy minimum required version 999.999-999; exiting!" ""
    assert "_clear_blip; . \"$blip\" 2>&1'" "" ""

    assert_end "${BASH_SOURCE[0]##*/}"
}

tests "$@"

