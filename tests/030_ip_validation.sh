#!/bin/bash

set -euo pipefail

. "${BASH_SOURCE[0]%/*}/assert.sh"
. "${BASH_SOURCE[0]%/*}/_clear_blip.sh"

tests () {
    declare -x blip="${BASH_SOURCE[0]%/*}/../blip.bash"
    _clear_blip
    source "$blip"

    # IPv4 address validation.
    declare test_input
    while read -r test_input ; do
        assert_raises "is_ipv4_address $test_input" 0 ""
    done < "${BASH_SOURCE[0]%/*}/ipv4_addresses"
    while read -r test_input ; do
        assert_raises "is_ipv4_address $test_input" 1 ""
    done < "${BASH_SOURCE[0]%/*}/non_ipv4_addresses"

    # IPv4 prefix validation.
    while read -r test_input ; do
        assert_raises "is_ipv4_prefix $test_input" 0 ""
    done < <(grep -v -- "-" "${BASH_SOURCE[0]%/*}/ipv4_prefixes")
    while read -r test_input ; do
        assert_raises "is_ipv4_prefix $test_input" 1 ""
    done < <(grep -- "-" "${BASH_SOURCE[0]%/*}/non_ipv4_prefixes")

    assert_end "${BASH_SOURCE[0]##*/}"
}

tests "$@"

