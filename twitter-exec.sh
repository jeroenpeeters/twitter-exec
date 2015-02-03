#!/bin/bash

me=`basename $0`
function usage(){
  echo "Usage: $me allowed-users..."
  echo "Polls Twitter for direct messages that contain an executable instruction and executes that instruction."
  echo "The instruction result is returned as a direct message to the sender."
  echo ""
  echo "Mandatory arguments:"
  echo "   allowed-users  A space-separated list of Twitter user-handles that are allowed to execute instructions"
  echo ""
  echo "Example: $me jeroenpeeters"
  exit 1
}
if [ $# -lt 1 ]; then
  usage
fi

users=$1

# Check if twidge is available
twidge=$(which twidge)
if [ -z "$twidge" ]; then
  echo "Unable to locate twidge. Is twidge installed?"
  echo "On Debian based systems:
  # sudo apt-get install twidge
  # twidge setup"
  echo "Or see https://github.com/jgoerzen/twidge/wiki"
  exit -1
fi

# Check if sed is available
if [ -z "$(which sed)" ]; then
  echo "Unable to locate sed. Is sed installed?"
  exit -1
fi

$twidge lsdm -su | cut -f1,3- -d '>' | while read -r instruction; do
  user=$(echo "$instruction" | grep -Po '\<.+\>')
  user="${user:1:${#user}-2}"
  cmd=$(echo "$instruction" | grep -Po 'exec:\s?\K.+')

  if [ -n "$cmd" ] && [ -n "$user" ]; then
    if [[ "$users" =~ "$user" ]]; then
      cmd=$(echo "$cmd" | sed "s/\&amp\;/\&/g") # &amp; => &
      echo "$user requested execution of: $cmd"
      result=$($cmd)
      $twidge dmsend "$user" "${result:0:140}" # return the first 140 chars of result
    else
      echo "$user is not authorized for twitter-exec"
    fi
  fi
done
