#!/bin/bash

set -euo pipefail

. "${BASH_SOURCE[0]%/*}/assert.sh"
. "${BASH_SOURCE[0]%/*}/_clear_blip.sh"

tests () {
    declare -x blip="${BASH_SOURCE[0]%/*}/../blip.bash"
    _clear_blip
    source "$blip"

    # Simple variable type tests.
    declare test_input
    for test_input in $(<"${BASH_SOURCE[0]%/*}/integers") ; do
        assert_raises "is_integer $test_input" 0 ""
        assert_raises "is_int $test_input" 0 ""
    done
    for test_input in $(<"${BASH_SOURCE[0]%/*}/non_integers") ; do
        assert_raises "is_integer $test_input" 1 ""
        assert_raises "is_int $test_input" 1 ""
    done
    for test_input in $(grep -v -- "-" "${BASH_SOURCE[0]%/*}/integers") ; do
        assert_raises "is_absolute_integer $test_input" 0 ""
        assert_raises "is_abs_int $test_input" 0 ""
    done
    for test_input in $(grep -- "-" "${BASH_SOURCE[0]%/*}/integers") ; do
        assert_raises "is_absolute_integer $test_input" 1 ""
        assert_raises "is_abs_int $test_input" 1 ""
    done

    # Save nocasematch original state.
    set +e
    shopt -q nocasematch
    declare -xi nocasematch=$?
    set -e

    shopt -s nocasematch
    for test_input in $(<"${BASH_SOURCE[0]%/*}/boolean_true") ; do
        assert_raises "is_true $test_input" 0 ""
        assert_raises "is_false $test_input" 1 ""
    done
    for test_input in $(<"${BASH_SOURCE[0]%/*}/boolean_false") ; do
        assert_raises "is_true $test_input" 1 ""
        assert_raises "is_false $test_input" 0 ""
    done

    shopt -u nocasematch
    for test_input in $(grep "[A-Z]" "${BASH_SOURCE[0]%/*}/boolean_true") ; do
        assert_raises "is_true $test_input" 1 ""
    done
    for test_input in $(grep -v "[A-Z]" "${BASH_SOURCE[0]%/*}/boolean_true") ; do
        assert_raises "is_true $test_input" 0 ""
    done
    for test_input in $(grep "[A-Z]" "${BASH_SOURCE[0]%/*}/boolean_false") ; do
        assert_raises "is_false $test_input" 1 ""
    done
    for test_input in $(grep -v "[A-Z]" "${BASH_SOURCE[0]%/*}/boolean_false") ; do
        assert_raises "is_false $test_input" 0 ""
    done

    # Reset nocasematch to original state.
    [[ "$nocasematch" -eq 0 ]] && shopt -s nocasematch

    assert_end "${BASH_SOURCE[0]##*/}"
}

tests "$@"

