#shellcheck shell=sh

to_linpath() {
  cygpath -u "$1"
}

to_winpath() {
  cygpath -aw "$1"
}
