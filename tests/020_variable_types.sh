#!/bin/bash

test_020_variable_types () {
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
    shopt -q nocasematch
    declare -xi nocasematch=$?

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

