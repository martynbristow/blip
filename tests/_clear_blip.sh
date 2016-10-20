_clear_blip () {
    while read -r _ _ var_stmt ; do
        declare -x var="${var_stmt%%=*}"
        if [[ "$var" =~ ^BLIP_.*$ ]] ; then
            unset "$var"
        fi
    done < <(typeset -x)
}
export -f _clear_blip
