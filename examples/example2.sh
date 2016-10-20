#!/bin/bash

# This is just pratting about local testing until I put together a proper suite
# of unit tests and what not.

set -euo pipefail

BLIP_ANSI_VARIABLES=1
BLIP_REQUIRE_VERSION="0.01-3"
source blip.bash
BLIP_DEBUG_LOGLEVEL=3

compgen -A variable | grep ANSI
echo "${!ANSI[@]}"
echo "${ANSI_FG_YELLOW}${ANSI_BOLD_ON}Hello world.${ANSI_RESET}"
echo "${ANSI[blink]}${ANSI[bg_white]}${ANSI[bold]}${ANSI[red]}${ANSI[underline]}Hello world.${ANSI[reset]}"

push_trap_stack "echo 'hello world'" INT
push_trap_stack "echo 'foo bar'" INT HUP
push_trap_stack "echo 'this will not appear'" INT HUP
pop_trap_stack INT
get_trap_stack INT
set_trap_stack "echo 'woop woop'" INT
get_trap_stack INT
get_trap_stack HUP
unset_trap_stack HUP
get_trap_stack HUP
push_trap_stack 'for ((x=0; x<=10; x++)) ; do echo " >> x=$x << "; done' INT HUP
push_trap_stack "echo 'The final countdown.'" INT

echo "${ANSI[bold]}${ANSI[cyan]}Try pressing Control-C to trigger a SIGINT trap handler stack.${ANSI[reset]}"
for ((i=6; i>=0; i--)); do
    echo "$i"
    sleep 1
done
echo "${ANSI[bold]}${ANSI[red]}Too late; better luck next time!${ANSI[reset]}"

set_trap_stack "echo 'Interrupted by user input.'" INT
set_trap_stack "echo 'Interrupted by signal.'" HUP

rc_to_colour () {
    if [[ ${1:-} -eq 0 ]] ; then
        echo '[0;1;32m'
    else
        echo '[0;1;31m'
    fi
}

while read -r command ; do
    result="$(eval "$command")"
    rc=$?
    echo -e "$(rc_to_colour "$rc")$command\e[0m [$rc] $result"
done << 'COMMANDS'
get_iso8601_date
get_unixtime
get_date
get_free_disk_space /
get_gecos_info email
get_gecos_name
get_gecos_name postgres
COMMANDS

set +e

while read -r addr ; do
    while read -r command ; do
        $command "$addr"
        rc=$?
        echo -e "$(rc_to_colour "$rc")$command \"$addr\"\e[0m [$rc]"
    done << 'COMMANDS'
is_ipv4_address
is_ipv4_prefix
is_ipv6_address
is_ipv6_prefix
COMMANDS
done << 'ADDRESSES'
10.10.10.10
10.10.10.10/8
10.10.10.10/40
300.300.300.300
::1
fe80::a/64
2000::aaaa::ffff
ADDRESSES

while read -r command ; do
    result="$(eval "$command")"
    rc=$?
    echo -e "$(rc_to_colour "$rc")$command\e[0m [$rc] $result"
done << 'COMMANDS'
url_exists http://www.bbc.co.uk
url_http_response_code http://www.bbc.co.uk
url_http_header http://www.bbc.co.uk
COMMANDS

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

