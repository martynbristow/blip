#!/bin/bash

set -ueo pipefail
shopt -s extglob
shopt -s nullglob

for test in "${BASH_SOURCE[0]%/*}"/+([0-9])[_-]*.sh
do
    bash "$test" "$@"
done

