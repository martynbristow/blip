#!/bin/bash

set -euo pipefail

. "${BASH_SOURCE[0]%/*}/assert.sh"
. "${BASH_SOURCE[0]%/*}/_clear_blip.sh"

tests () {
    declare -x blip="${BASH_SOURCE[0]%/*}/../blip.bash"
    declare -x pod="${blip}.pod"
    declare -x man3="${blip}.3"
    _clear_blip
    source "$blip"

    # Check all functions are documented.
    while read -r function ; do
        function="${function%% *}"
        assert_raises "grep '^=head2 $function ' '$pod'" 0 ""
    done < <(egrep -o '^[a-z_]+\ \(\)' "$blip" | sort -u)

    # Check all BLIP_ variables are documented.
    while read -r variable ; do
        assert_raises "grep -w '^=head2 $variable' '$pod'" 0 ""
    done < <(compgen -v | grep ^BLIP_)

    # Check blip(3) man page is a similar age to the pod.
    declare -xi pod_age="$(get_file_age "$pod")"
    declare -xi man3_age="$(get_file_age "$man3")"
    assert_raises '[[ $(( man3_age - pod_age )) -le 60 ]]' 0 ""

    assert_end "${BASH_SOURCE[0]##*/}"
}

tests "$@"

