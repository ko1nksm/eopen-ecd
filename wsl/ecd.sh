#!/bin/sh

abort() {
  [ $# -gt 0 ] && printf '%s\n' "printf 'ecd: %s\n' '$*' >/dev/stderr"
  echo false
  exit 1
}

pwsh() {
  powershell.exe -NoProfile -ExecutionPolicy Unrestricted "$@"
}

ewd() {
  cd "$(dirname "$0")" || exit 1
  pwsh ../bridge/ewd.ps1
}

ewd=$(ewd) || abort

case $ewd in ([A-Za-z]:* | \\\\*)
  if dest=$(wslpath -u "$ewd") 2>/dev/null; then
    # shellcheck disable=SC2028
    echo "cd \"$dest\"; printf '%s\n' \"$dest\""
    exit
  fi
esac

abort "Unable to move to $ewd"
exit 1
