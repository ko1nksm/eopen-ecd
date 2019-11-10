#!/bin/sh

set -eu
tmpfile=$1 orgfile=$2

printf "Waiting for the file changes... "
while true; do
  sleep 1
  #shellcheck disable=SC2039
  if [ "$tmpfile" -nt "$orgfile" ] || [ "$tmpfile" -ot "$orgfile" ]; then
    printf "\rWrite back to '%s'... " "$orgfile"
    cp --preserve=timestamps "$tmpfile" "$orgfile"
    date +"Done. [%T]"
    printf "Waiting for the file changes... "
  fi
done
