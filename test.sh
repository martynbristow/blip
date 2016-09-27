#!/bin/bash

# This is just pratting about local testing until I put together a proper suite
# of unit tests and what not.

set -euxo pipefail

source blip.bash

while read -r command ; do
    result="$(eval $command)"
    echo -e "\e[0;1;33m$command\e[0m : $result"
done << 'COMMANDS'
get_iso8601_date
get_unixtime
get_date
get_free_disk_space /
get_gecos_info email
get_gecos_name
get_gecos_name postgres
COMMANDS

set +xe

get_user_selection "Abort, retry, fail?" "f" "a" "r" "f"
echo rc=$?

get_user_selection "Abort, retry, fail?" "" "a" "r" "f"
echo rc=$?

get_user_confirmation "Continue?"
echo rc=$?

get_user_confirmation "Continue?" "y"
echo rc=$?

get_user_confirmation "Continue?" "n"
echo rc=$?

