#shellcheck shell=sh

ecd() {
  typeset ewd

  ewd=$(
    cd "$EOPEN_ROOT" || exit 1
    bin/ebridge.exe pwd
  ) || return 1

  case $ewd in ([A-Za-z]:* | \\\\*)
    if ewd=$(wslpath -u "$ewd" 2>/dev/null); then
      cd "$ewd"
      printf '%s\n' "$ewd"
      return 0
    fi
  esac

  printf "Unable to move to '%s'\n" "$ewd"
  return 1
}
