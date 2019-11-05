#!/bin/sh

set -eu

ebridge="$EOPEN_ROOT/bin/ebridge.exe"

abort() {
  printf 'eopen: %s\n' "$*" >&2
  exit 1
}

ebridge() (
  cd "${ebridge%/*}" || exit 1
  "./${ebridge##*/}" "$@"
)

is_windrive() {
  case $1 in
    [a-zA-Z]:) return 0
  esac
  return 1
}

is_winpath() {
  case $1 in
    [a-zA-Z]:[\\/]*) return 0
  esac
  return 1
}

is_wslpath() {
  case $1 in
    [\\/][\\/]wsl\$[\\/]*) return 0
  esac
  return 1
}

is_uncpath() {
  case $1 in
    [\\/][\\/]*) return 0
  esac
  return 1
}

is_protocol() {
  case $1 in (*:*)
    case ${1%%:*} in (*[!0-9a-zA-Z.+-]*)
      return 1
    esac
    return 0
  esac
  return 1
}

usage() {
  cat <<'HERE'
Usage: eopen [options] [file | directory | uri]

options:
  -e, --editor      Open the file in text editor. Set the editor path to
                      EOPEN_EDITOR environment variable on Windows.
  -n, --new         Open the specified directory in new instance of explorer.
      --sudo        Use sudo to edit the unowned file.
  -g, --background  Does not bring the application to the foreground.
  -v, --version     Display the version.
  -h, --help        You're looking at it.

note:
  The file or the directory allows linux and windows path.
    e.g. /etc/hosts, C:/Windows/System32/drivers/etc/hosts, \\wsl$\\Ubuntu
  The uri must start with protocol schema.
    e.g. http://example.com, https://example.com
HERE
exit
}

EDITOR='' NEW='' SUDO='' FLAGS=''

for arg; do
  case $arg in
    -e | --editor    ) EDITOR=1 ;;
    -n | --new       ) NEW=1 ;;
         --sudo      ) SUDO=1 ;;
    -g | --background) FLAGS="${FLAGS}b" ;;
    -v | --version   ) ebridge version; exit ;;
    -h | --help      ) usage ;;
    -?*) abort "unrecognized option '$arg'" ;;
    *) set -- "$@" "$arg"
  esac
  shift
done

[ $# -eq 0 ] && set -- .
set -- "$1"
origpath="$1"

if [ -e "$1" ]; then
  path=$(readlink -f "$1")
  set -- "$path"
else
  case $1 in "~~" | "~~/"* |  "~~\\"*)
    whome=$(ebridge env USERPROFILE)
    set -- "$whome${1#~~}"
  esac

  is_windrive "$1" && set -- "$1\\"
  if is_winpath "$1" || is_wslpath "$1"; then
    path=$(wslpath -au "$1") 2>/dev/null && set -- "$path"
  fi
fi

main() {
  if [ "$EDITOR" ]; then
    if [ -e "$1" ] && [ ! -w "$1" ]; then
      echo 'Warning, do not have write permission' >&2
    fi
    func=edit
  else
    [ "$NEW" ] && func=new || func=open
  fi

  if is_winpath "$1" || is_protocol "$1" || is_uncpath "$1"; then
    path=$1
  else
    path=$(wslpath -aw "$1")
  fi

  ebridge "$func" "$path" "$FLAGS"
}

if [ "$SUDO" ]; then
  [ -f "$1" ] || abort "'$origpath' is not a file"
  tmpdir='' tmpfile=''

  cleanup() {
    if [ -f "$tmpfile" ]; then
      printf '\n%s\n' "Delete tempfile '$tmpfile'"
      rm "$tmpfile"
      [ -d "$tmpdir" ] && rmdir "$tmpdir"
    fi
    exit
  }
  trap cleanup INT TERM EXIT

  tmpdir=$(mktemp -d)
  orgfile="$1" tmpfile=$tmpdir/${1##*/}
  cp --preserve=timestamps "$orgfile" "$tmpfile"
  printf "Copy '%s' to '%s'\n" "$orgfile" "$tmpfile"
  set -- "$tmpfile"

  main "$@"

  printf 'Waiting for the file changes... To stop, press CTRL-C'
  while true; do
    sleep 1 ||:
    #shellcheck disable=SC2039
    if [ "$tmpfile" -nt "$orgfile" ]; then
      printf '\nThe file changes detected\n'
      sudo cp "$tmpfile" "$orgfile"
      printf '%s' "Wrote '$orgfile'"
    fi
  done
else
  main "$@"
fi
