#!/bin/sh

set -eu
tmpfile=$1 orgfile=$2

printf "Waiting for the file changes... "
while true; do
  sleep 1
  #shellcheck disable=SC2039
  [ "$tmpfile" -nt "$orgfile" ] || continue
  printf "\rWrite back to '%s'... " "$orgfile"
  cp "$tmpfile" "$orgfile"
  date +"Done. [%T]"
  printf "Waiting for the file changes... "
done
