#!/bin/bash

set -euxo pipefail

# blip - Bash Library for Indolent Programmers

# Author: Nicola Worthington <nicolaw@tfb.net>
#         Sergej Alikov

# Some inspirational sources:
#   https://nicolaw.uk/bash
#   http://mywiki.wooledge.org/BashFAQ
#   https://code.google.com/archive/p/bsfl/downloads
#   https://bash.cyberciti.biz/guide/Shell_functions_library
#   http://www.bashinator.org/
#   https://dberkholz.com/2011/04/07/bash-shell-scripting-libraries/

# Get a nice list of bash built-ins without forking crap for formatting:
#     while read -r _ cmd ; do echo $cmd ; done < <(enable -a)

# Attempted function naming conventions:
#   is_*    An evaluation test that returns boolean true or false only.
#           No STDOUT should be emitted.
#
#   to_*    Data manipulation that returns results through STDOUT.
#
#   get_*   Gathers some information which is returned through STDOUT.
#           Newline characters should be omitted from output when only
#           a single line of output is ever expected.

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

# Return the time since the epoch in seconds.
get_unixtime () {
    if [[ ${BASH_VERSINFO[0]} -ge 4 && ${BASH_VERSINFO[1]} -ge 2 ]] ; then
        printf '%(%s)T\n' -1
    else
        date +%s
    fi
}

# %w %W  time of file birth; - or 0 if unknown (creation)
# %x %X  time of last access, human-readable (read)
# %y %Y  time of last modification, human-readable (content)
# %z %Z  time of last change, human-readable (meta data)
get_file_age () {
    echo -n $(( $(get_unixtime) - $(stat -c %Y "${1:-}") ))
}

