#!/bin/bash

source blip.bash

counter () {
  declare -i i
  for ((i=0; i<=4; i++)) ; do 
    echo "$(( $(printf '%(%s)T' -1) - $(printf '%(%s)T' -2) ))"
    sleep 0.6
  done
}

echo "Hello world!"

counter "$@"

declare -x foo="BAR MEH BLERG"
echo "Woop ${foo##* }!"

