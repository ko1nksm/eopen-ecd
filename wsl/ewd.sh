#!/bin/sh

set -eu

abort() {
  [ $# -gt 0 ] && printf 'ewd: %s\n' "$1" >&2
  exit 1
}

ewd=$(
  cd "$EOPEN_ROOT" || exit 1
  bin/ebridge.exe pwd
) || abort

case $ewd in ([A-Za-z]:* | \\\\*)
  if dest=$(wslpath -u "$ewd") 2>/dev/null; then
    printf '%s\n' "$dest"
    exit
  fi
esac

abort "Unsupported path '$ewd'"
