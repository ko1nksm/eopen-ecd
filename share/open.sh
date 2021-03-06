#shellcheck shell=sh

set -eu

usage() {
  cat <<'HERE'
Usage: eopen [options] [file | directory | uri | keywords]

options:
  -e, --editor      Open the file in text editor. Set the editor path to
                      EOPEN_EDITOR environment variable on Windows.
  -S, --web-search  Web search, open in browser.
  -n, --new         Open the specified directory in new instance of explorer.
HERE
if [ "$ENABLE_SUDO" ]; then
  cat <<'HERE'
      --sudo        Use sudo to edit the unowned file.
HERE
fi
  cat <<'HERE'
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

abort() {
  printf 'eopen: %s\n' "$*" >&2
  exit 1
}

ebridge() (
  cd "$EOPEN_ROOT" || exit 1
  bin/ebridge.exe "$@"
)

is_linux_path() {
  case $1 in ([a-zA-Z]: | [a-zA-Z]:[\\/]*) return 1; esac # Windows path
  case $1 in ("~~" | "~~"[\\/]*) return 1; esac # Windows home path
  case $1 in ([\\/][\\/]*) return 1; esac # UNC or WSL path
  case $1 in (: | :[\\/]*) return 1; esac # Exploler Location
  case $1 in (:*) return 1; esac # Shell special folder
  case $1 in (*:*)
    case ${1%%:*} in (*[!0-9a-zA-Z.+-]*) return 0; esac
    return 1; # protocol
  esac
}

is_crumb() {
  case $1 in ([a-zA-Z]:*) return 1; esac # Windows path
  case $1 in (*:*) return 0; esac
  return 1
}

check_path() {
  [ -e "$1" ]
}

check_edit_path() {
  [ -e "$1" ] || [ -d "$(dirname "$1")" ]
}

EDITOR='' WEB='' SEARCH='' SEARCH='' NEW='' SUDO='' FLAGS=''

ENABLE_SUDO=''
if type sudo > /dev/null 2>&1; then
  ENABLE_SUDO=1
fi

unknown() { abort "unrecognized option '$1'";  }
for arg; do
  case $arg in
    -e | --editor     ) EDITOR=1 ;;
    -s | --search     ) SEARCH=1 WEB='' ;;
    -S | --web-search ) SEARCH=1 WEB=1  ;;
    -n | --new        ) NEW=1 ;;
         --sudo       ) [ "$ENABLE_SUDO" ] || unknown "$@"; SUDO=1 ;;
    -g | --background ) FLAGS="${FLAGS}b" ;;
    -v | --version    ) ebridge version; exit ;;
    -h | --help       ) usage ;;
    -?*) unknown "$@" ;;
    *) set -- "$@" "$arg"
  esac
  shift
done

if [ "$SEARCH" ]; then
  if [ "$WEB" ]; then
    ebridge web-search "${1:-}" "$FLAGS" "$@"
  else
    query=${1:-}
    [ $# -gt 0 ] && shift
    location=$(to_winpath ./)
    for crumb; do
      shift
      is_crumb "$crumb" && set -- "$@" "$crumb" && continue
      location="$crumb"
      is_linux_path "$location" && location=$(to_winpath "$location")
    done
    ebridge search "$query" "$FLAGS" "$location" "$@"
  fi
  exit
fi

set -- "${1:-}"

if [ "$SUDO" ]; then
  is_linux_path "$1" || abort "'$1' is not linux path"
  [ -f "$1" ] || abort "'$1' is not a file"

  tmpdir='' tmpfile=''
  cleanup() {
    [ -f "$tmpfile" ] && printf "\nDelete tempfile '%s'\n" "$tmpfile"
    [ -f "$tmpfile" ] && rm "$tmpfile"
    [ -d "$tmpdir" ] && rmdir "$tmpdir"
    exit
  }
  trap cleanup INT TERM EXIT

  tmpdir=$(mktemp -d)
  orgfile=$1 tmpfile=$tmpdir/${1##*/}
  printf "Copied temporarily to '%s'.\n" "$tmpfile"
  cp --preserve=timestamps "$orgfile" "$tmpfile"
  set -- "$tmpfile"
fi

case $1 in ("~~" | "~~"[\\/]*) # Windows home path
  path=$(ebridge env USERPROFILE)
  set -- "$path${1#~~}"
esac

if [ "$1" ] && is_linux_path "$1"; then
  path=$(readlink -f "$1")
  check_${EDITOR:+edit_}path "$path" || abort "No such file or directory"
  if [ "$EDITOR" ] && [ ! -w "$1" ]; then
    echo 'Warning, do not have write permission.' >&2
  fi
  path=$(to_winpath "$path")
  set -- "$path"
fi

func=open
[ "$NEW" ] && func=new
[ "$EDITOR" ] && func=edit
printf '\033]0;%s\a' "eopen: $$"
ebridge "$func" "$1" "$FLAGS" "eopen: $$"

if [ "$SUDO" ]; then
  echo "Press CTRL-C to stop when finished editing the file"
  sudo sh "$EOPEN_ROOT/share/sudo-watch.sh" "$tmpfile" "$orgfile"
fi
