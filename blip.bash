#!/bin/bash
#
# blip - Bash Library for Indolent Programmers
#
# Please see the man page blip.bash(3) or bash.pod for full documentation.
#
# https://nicolaw.uk/blip
# https://github.com/neechbear/blip/
# https://github.com/neechbear/blip/blob/master/blip.bash.pod
#
# MIT License
#
# Copyright (c) 2016 Nicola Worthington
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Some inspirational sources:
#   https://nicolaw.uk/bash
#   http://mywiki.wooledge.org/BashFAQ
#   https://code.google.com/archive/p/bsfl/downloads
#   https://bash.cyberciti.biz/guide/Shell_functions_library
#   http://www.bashinator.org/
#   https://dberkholz.com/2011/04/07/bash-shell-scripting-libraries/
#   https://github.com/Dieterbe/libui-sh/blob/master/libui.sh
#
# Get a nice list of bash built-ins without forking crap for formatting:
#     while read -r _ cmd ; do echo $cmd ; done < <(enable -a)
#
# Preferred function naming conventions:
#   is_*    An evaluation test that returns boolean true or false only.
#           No STDOUT should be emitted.
#
#   to_*    Data manipulation that returns results through STDOUT.
#
#   get_*   Gathers some information which is returned through STDOUT.
#           Newline characters should be omitted from output when only
#           a single line of output is ever expected.

# Try and bail out early if we detect that we are probably not running
# from inside a bash shell interpreter. You may disable the exit on
# non-Bash shell functionality by setting BLIP_ALLOW_FOREIGN_SHELLS=1.
if [ "x$BASH" = "x" ] || [ "x$BASH_VERSION" = "x" ] || [ "x$BASHPID" = "x" ] ; then
    case "x$BLIP_ALLOW_FOREIGN_SHELLS" in
        x1|xyes|xtrue|xon|xenable|xenabled) true ;;
        *)
            echo "blip.bash detected a foreign shell interpreter is running;" \
                 "exiting!" >&2
            exit 2
    esac
fi

# TODO(nicolaw): Work out how to automatically populate these values at build
#                and release (packaging) time.
declare -rg BLIP_VERSION="0.01-3-prerelease"
declare -rga BLIP_VERSINFO=("0" "01" "3" "prerelease")
if     [[ -n "${BLIP_REQUIRE_VERSION:-}" ]] ; then
    declare -a BLIP_REQUIRE_VERSINFO=(${BLIP_REQUIRE_VERSION//[-.]/ })
    if   [[ ${BLIP_REQUIRE_VERSINFO[0]:-} -gt ${BLIP_VERSINFO[0]} ]] \
      || [[ ${BLIP_REQUIRE_VERSINFO[1]:-} -gt ${BLIP_VERSINFO[1]} ]] \
      || [[ ${BLIP_REQUIRE_VERSINFO[2]:-} -gt ${BLIP_VERSINFO[2]} ]] ; then
        echo "blip.bash version $BLIP_VERSION does not satisfy minimum" \
             "required version $BLIP_REQUIRE_VERSION; exiting!" >&2
        exit 2
    fi
fi

# Assign command names to run from $PATH unless otherwise already defined.
BLIP_EXTERNAL_CMD_CURL="${BLIP_EXTERNAL_CMD_CURL:-curl}"
BLIP_EXTERNAL_CMD_DATE="${BLIP_EXTERNAL_CMD_DATE:-date}"
BLIP_EXTERNAL_CMD_GREP="${BLIP_EXTERNAL_CMD_GREP:-grep}"
BLIP_EXTERNAL_CMD_EGREP="${BLIP_EXTERNAL_CMD_EGREP:-egrep}" # Remove this dependency!

# Return the length of the longest argument.
get_max_length () {
    local max=0
    for arg in "$@" ; do
        if [[ ${#arg} -gt $max ]] ; then
            max="${#arg}"
        fi
    done
    echo -n "$max"
}

get_string_characters () {
    local string="${1:-}"
    local -i i=0
    for (( i=0; i<${#string}; i++ )); do
      echo "${string:$i:1}"
    done
}

# Functionality to add:
#    - Add get_user_input() - multi character user input without defaults
#    - Add process locking functions
#    - Add background daemonisation functions (ewww - ppl should use systemd)
#    - Add standard logging functions
#    - Add syslogging functionality of all process STDOUT + STDERR
#    - Add console colour output options

# Ask the user for confirmation, expecting a single character y or n reponse.
# Returns 0 when selecting y, 1 when selecting n.
get_user_confirmation () {
    local question="${1:-Are you sure?}"
    local default_response="${2:-}"
    get_user_selection "$question" "$default_response" "y" "n"
}

get_user_selection () {
    local question="${1:-Make a selection }"; shift
    local default_response="${1:-}"; shift
    local max_response_length="$(get_max_length "$@")"

    # Replace with a standard argument validation routine.
    # http://tldp.org/LDP/abs/html/exitcodes.html
    if [[ $max_response_length -ne 1 ]] ; then
        >&2 echo "get_user_selection() <question_prompt> <default_response> <valid_responseN>..."
        >&2 echo "No valid_reponse arguments were passed, or 1 or more valid_response arguments were not exactly 1 character in length."
        return 126
    fi

    local prompt=""
    for arg in "$@" ; do
        if [[ "$arg" = "$default_response" ]] ; then
            arg="*$arg"
        fi
        prompt="${prompt:+$prompt|}$arg"
    done

    local input=""
    while read -n 1 -e -r -p "${question}${prompt:+ [$prompt]: }" input ; do
        if [[ -z "$input" ]] ; then
            input="$default_response"
        fi

        local -i rc=0
        for valid_response in "$@" ; do
            if [[ "$input" = "$valid_response" ]] ; then
                return $rc
            fi
            rc=$((rc+1))
        done
    done
}

# https://en.wikipedia.org/wiki/ISO_8601
get_iso8601_date () { get_date "%Y-%m-%d" "$@"; }

# Return the time since the epoch in seconds.
get_unixtime () { get_date "%s" "$@"; }

get_date () {
    local format="${1:-%a %b %d %H:%M:%S %Z %Y}"
    local when="${2:--1}"
    if [[ ${BASH_VERSINFO[0]} -ge 4 && ${BASH_VERSINFO[1]} -ge 2 ]] ; then
        printf "%($format)T\n" $when
    else
        if [[ "$when" = "-1" ]] ; then
            when=""
        fi
        $BLIP_EXTERNAL_CMD_DATE ${when:+-d "$when"} +%s
    fi
}

url_http_header () {
    $BLIP_EXTERNAL_CMD_CURL -s -I "$1"
}

url_http_response_code () {
    url_http_header "$1" | $BLIP_EXTERNAL_CMD_GREP ^HTTP
}

url_exists () {
    local url="$1"
    if [[ "$url" =~ ^file:// ]] ; then
        $BLIP_EXTERNAL_CMD_CURL -s -I "$url" -o /dev/null 2>/dev/null
    else
        url_http_response_code "$url" \
            | $BLIP_EXTERNAL_CMD_EGREP -qw '^HTTP[^ ]* 2[0-9][0-9]'
    fi
}

is_in_path () {
    local cmd
    for cmd in "$@" ; do
        if ! type -P "$cmd" >/dev/null 2>&1 ; then
             return 1
        fi
    done
    return 0
}

is_ipv4_address () {
    local regex='(?<![0-9])(?:(?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5]))(?![0-9])'
    $BLIP_EXTERNAL_CMD_GREP -Pq "^$regex$" <<< "${1:-}"
}

is_ipv4_prefix () {
    local ip="${1%%/*}"
    local prefix="${1##*/}"
    if is_ipv4_address "$ip" && is_integer "$prefix" &&
        [[ $prefix -ge 0 ]] && [[ $prefix -le 32 ]] ; then
        return 0
    fi
    return 1
}

is_ipv6_address () {
    local regex='((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?'
    $BLIP_EXTERNAL_CMD_GREP -Pq "^$regex$" <<< "${1:-}"
}

is_ipv6_prefix () {
    local ip="${1%%/*}"
    local prefix="${1##*/}"
    if is_ipv6_address "$ip" && is_integer "$prefix" &&
        [[ $prefix -ge 0 ]] && [[ $prefix -le 128 ]] ; then
        return 0
    fi
    return 1
}

get_free_disk_space () {
    while read -r _ blocks _ ; do
        if is_integer "$blocks" ; then
            echo "$(( blocks * 1000 ))"
        fi
    done < <(df -kP "$1")
}

get_username () {
    local user="${USER:-$LOGNAME}"
    user="${user:-$(id -un)}"
    echo "${user:-$(whoami)}"
}

get_gecos_name () {
    get_gecos_info "name" "$@"
}

# https://en.wikipedia.org/wiki/Gecos_field
get_gecos_info () {
    local key="${1:-}"
    local user="${2:-$(get_username)}"
    while IFS=: read username passwd uid gid gecos home shell ; do
        if [[ "$user" = "$username" ]] ; then
            if [[ -n "$key" ]] && [[ "$gecos" =~ ([,;]) ]] ; then
                IFS="${BASH_REMATCH[1]}" read name addr office home email <<< "$gecos"
                case "$key" in
                    *name) echo "$name" ;;
                    building|room|addr*) echo "$addr" ;;
                    office*) echo "$office" ;;
                    home*) echo "$home" ;;
                    *) echo "$email" ;;
                esac
            elif [[ -z "$key" ]] || [[ "$key" = "name" ]] ; then
                echo "$gecos"
            fi
            break
        fi
    done < <(getent passwd "$user")
}

# English language boolean true or false.
is_true () { [[ "${1:-}" =~ ^yes|on|enabled?|true|1$ ]]; }
is_false () { [[ "${1:-}" =~ ^no|off|disabled?|false|0$ ]]; }
is_boolean () { is_true "$@" || is_false "$@"; }

# Evaulates if single argument input is an integer.
is_int () { [[ "${1:-}" =~ ^-?[0-9]+$ ]]; }
is_integer () { is_int "$@"; }

# Evaluates if single argument input is an absolute integer.
is_abs_int () { [[ "${1:-}" =~ ^[0-9]+$ ]]; }
is_absolute_integer () { is_abs_int "$@"; }

# Converts single argument input to an absolute value.
abs () {
    if [[ ${1:-} -lt 0 ]] ; then
        echo -n "${1:-}"
    else
        echo -n $(( ${1:-} * -1 ))
    fi
}
absolute () { abs "$@"; }

# Convert one or more words to uppercase without explicit variable substition.
# (Not meant as a replacement for tr in a pipeline).
to_upper () {
    for word in "$@" ; do
        echo "${word^^}"
    done
}

# Convert one or more words to lowercase without explicit variable substition.
# (Not meant as a replacement for tr in a pipeline).
to_lower () {
    for word in "$@" ; do
        echo "${word,,}"
    done
}

# Evaluates if argument2 is present as distinct word in argument1.
# Equivalent of grep -w.
# TODO: Should this be extended to have is_word_in_strings, and/or
#       is/are_words_in_string variants? Would that be overkill?
is_word_in_string () {
    local str="${1:-}"
    local re="\\b${2:-}\\b"
    [[ "$str" =~ $re ]] && return 0
    return 1
}

# Append a list of word(s) to argument1 if they are not already present as
# distinct words.
append_if_not_present () {
    local base_str="${1:-}"; shift
    for add_str in "$@" ; do
        if ! matches_word "$base_str" "$add_str" ; then
            base_str="${base_str} ${add_str}"
        fi
    done
    echo "${base_str## }"
}

# Returns all mount points, optionally filtered by device.
get_fs_mounts () {
    local device
    [[ -z "${1:-}" ]] || device=$(readlink -f "${1}")
    while IFS=" " read -r source target rest; do
        # Need echo -e to unescape source/target.
        if [[ -z "${device:-}" || "$(echo -e "${source}")" = "${device}" ]] ; then
            echo -e "${target}"
        fi
    done < /proc/mounts
}

# %w %W  time of file birth; - or 0 if unknown (creation)
# %x %X  time of last access, human-readable (read)
# %y %Y  time of last modification, human-readable (content)
# %z %Z  time of last change, human-readable (meta data)
get_file_age () {
    echo -n $(( $(get_unixtime) - $(stat -c %Y "${1:-}") ))
}

