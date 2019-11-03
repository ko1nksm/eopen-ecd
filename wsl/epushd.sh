#!/bin/sh

set -eu

ebridge="${0%/*}/../bin/ebridge.exe"

abort() {
  if [ $# -gt 0 ]; then
    printf '%s\n' "printf 'epushd: %s' '$*' >/dev/stderr; echo >/dev/stderr"
  fi
  echo false
  exit 1
}

ebridge() (
  cd "${ebridge%/*}" || exit 1
  "./${ebridge##*/}" "$@"
)

ewd=$(ebridge pwd) || abort

case $ewd in ([A-Za-z]:* | \\\\*)
  if dest=$(wslpath -u "$ewd") 2>/dev/null; then
    # shellcheck disable=SC2028
    echo "pushd \"$dest\"; echo"
    exit
  fi
esac

abort "Unable to move to $ewd"
exit 1
