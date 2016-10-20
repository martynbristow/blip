#!/bin/bash

set -euo pipefail

# shellcheck source=assert.sh
. "${BASH_SOURCE[0]%/*}/assert.sh"
# shellcheck source=_clear_blip.sh
. "${BASH_SOURCE[0]%/*}/_clear_blip.sh"

tests () {
    # shellcheck source=../blip.bash
    declare -x blip="${BASH_SOURCE[0]%/*}/../blip.bash"
    _clear_blip
    source "$blip"

    # Simple variable type tests.
    declare test_input
    while read -r test_input ; do
        assert_raises "is_integer $test_input" 0 ""
        assert_raises "is_int $test_input" 0 ""
    done < "${BASH_SOURCE[0]%/*}/integers"
    while read -r test_input ; do
        assert_raises "is_integer $test_input" 1 ""
        assert_raises "is_int $test_input" 1 ""
    done < "${BASH_SOURCE[0]%/*}/non_integers"
    while read -r test_input ; do
        assert_raises "is_absolute_integer $test_input" 0 ""
        assert_raises "is_abs_int $test_input" 0 ""
    done < <(grep -v -- "-" "${BASH_SOURCE[0]%/*}/integers")
    while read -r test_input ; do
        assert_raises "is_absolute_integer $test_input" 1 ""
        assert_raises "is_abs_int $test_input" 1 ""
    done < <(grep -- "-" "${BASH_SOURCE[0]%/*}/integers")

    # Save nocasematch original state.
    set +e
    shopt -q nocasematch
    declare -xi nocasematch=$?
    set -e

    shopt -s nocasematch
    while read -r test_input ; do
        assert_raises "is_true $test_input" 0 ""
        assert_raises "is_false $test_input" 1 ""
    done < "${BASH_SOURCE[0]%/*}/boolean_true"
    while read -r test_input ; do
        assert_raises "is_true $test_input" 1 ""
        assert_raises "is_false $test_input" 0 ""
    done < "${BASH_SOURCE[0]%/*}/boolean_false"

    shopt -u nocasematch
    while read -r test_input ; do
        assert_raises "is_true $test_input" 1 ""
    done < <(grep "[A-Z]" "${BASH_SOURCE[0]%/*}/boolean_true")
    while read -r test_input ; do
        assert_raises "is_true $test_input" 0 ""
    done < <(grep -v "[A-Z]" "${BASH_SOURCE[0]%/*}/boolean_true")
    while read -r test_input ; do
        assert_raises "is_false $test_input" 1 ""
    done < <(grep "[A-Z]" "${BASH_SOURCE[0]%/*}/boolean_false")
    while read -r test_input ; do
        assert_raises "is_false $test_input" 0 ""
    done < <(grep -v "[A-Z]" "${BASH_SOURCE[0]%/*}/boolean_false")

    # Reset nocasematch to original state.
    [[ "$nocasematch" -eq 0 ]] && shopt -s nocasematch

    assert_end "${BASH_SOURCE[0]##*/}"
}

tests "$@"

