#!/bin/bash

set -uo pipefail
shopt -s extglob
shopt -s nullglob

source "${BASH_SOURCE[0]%/*}/assert.sh"
source "${BASH_SOURCE[0]%/*}/../blip.bash"

# Source all of the unit test shell scripts.
for test_file in "${BASH_SOURCE[0]%/*}"/+([0-9])[_-]*.sh
do
    source "$test_file"
done

# Run all of the unit test functions.
while read -r test_func
do
    $test_func "$@"
done < <(compgen -A function | egrep '^test_[0-9]+_' | sort -n)

