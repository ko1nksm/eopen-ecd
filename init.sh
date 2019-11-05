#!/bin/sh

set -eu

BASE=$(cd "$(dirname "$0")"; pwd)

if [ ! -x "$BASE/bin/ebridge.exe" ]; then
  echo "ebridge.exe not found or is not executable: '$BASE/bin/ebridge.exe'" >&2
  exit 1
fi

case ${1:-sh} in

(sh) cat<<HERE
EOPEN_ROOT="$BASE"
alias eopen='sh "$BASE/wsl/eopen.sh"'
alias ewd='sh "$BASE/wsl/ewd.sh"'
. "$BASE/wsl/ecd.sh"
if type pushd >/dev/null 2>&1; then
. "$BASE/wsl/epushd.sh"
fi
HERE
;;

(tcsh) cat<<HERE
alias eopen 'sh "$BASE/wsl/eopen.sh"';
alias ewd 'sh "$BASE/wsl/ewd.sh"';
alias ecd 'eval `sh "$BASE/wsl/ecd.sh"`';
alias epushd 'eval `sh "$BASE/wsl/epushd.sh"`';
HERE
;;

(fish) cat<<HERE
set EOPEN_ROOT "$BASE";
alias eopen='sh "$BASE/wsl/eopen.sh"';
alias ewd='sh "$BASE/wsl/ewd.sh"';
source "$BASE/wsl/ecd.fish"
source "$BASE/wsl/epushd.fish"
HERE
;;

(*) echo "Invalid shell type" >&2

esac
