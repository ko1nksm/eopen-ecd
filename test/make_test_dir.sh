#!/bin/sh

set -eu

eval "$(printf "
  SOH='\\001' STX='\\002' ETX='\\003' EOT='\\004'
  ENQ='\\005' ACK='\\006' BEL='\\007' BS='\\010'
  HT='\\011'  TAB='\\011' LF='\\012'  VT='\\013'
  FF='\\014'  CR='\\015'  SO='\\016'  SI='\\017'
  DLE='\\020' DC1='\\021' DC2='\\022' DC3='\\023'
  DC4='\\024' NAK='\\025' SYN='\\026' ETB='\\027'
  CAN='\\030' EM='\\031'  SUB='\\032' ESC='\\033'
  FS='\\034'  GS='\\035'  RS='\\036'  US='\\037' DEL='\\177'
")"

cd "$(dirname "$0")"

echo "This will create a test directory under '$PWD/test_dirs'"
echo "Press enter key to continue . . ."
# shellcheck disable=SC2034
read -r line

make_dir() {
  dir=$(printf 'test_dirs/%s' "$1")
  command mkdir -p "$dir"
  echo "Created: $dir"
}

mkdir -p test_dirs
make_dir "01 U+0009 $TAB TAB"
make_dir "02 U+000A $LF LF"
make_dir "03 U+000B $VT VT"
make_dir "04 U+000D $CR CR"
make_dir '05 U+0021 ! Exclamation Mark'      # [warn] cmd
make_dir '06 U+0022 " Quotation Mark'
make_dir '07 U+0023 # Number Sign'
make_dir '08 U+0024 $ Dollar Sign'
make_dir '09 U+0025 % Percent Sign'          # [warn] cmd
make_dir '10 U+0026 & Ampersand'             # [warn] cmd
make_dir "11 U+0027 ' Apostrophe"
make_dir '12 U+0028 ( Left Parenthesis'
make_dir '13 U+0029 ) Right Parenthesis'
make_dir '14 U+0030 * Asterisk'
make_dir '15 U+0031 + Plus Sign'
make_dir '16 U+0032 , Comma'                 # [warn] cmd
make_dir '17 U+0033 - Hyphen-Minus'
make_dir '18 U+0034 . Full Stop'
make_dir '19 U+003A : Colon'
make_dir '20 U+003B ; Semicolon'
make_dir '21 U+003C < Less-Than Sign'
make_dir '22 U+003D = Equals Sign'
make_dir '23 U+003E > Greater-Than Sign'
make_dir '24 U+003F ? Question Mark'
make_dir '25 U+0040 @ Commercial At'
make_dir '26 U+005B [ Left Square Bracket'
make_dir '27 U+005C \ Reverse Solidus'
make_dir '28 U+005D ] Right Square Bracket'
make_dir '29 U+005E ^ Circumflex Accent'     # [warn] cmd
make_dir '30 U+005F - Low Line'
make_dir '31 U+0060 ` Grave Accent'
make_dir '32 U+007E ~ Tilde'
make_dir "33 U+007F $DEL DEL"
make_dir "34 U+2665 ♥ Black Heart Suit"    # [warn] cmd
make_dir "35 U+1F340 🍀 Four Leaf Clover"  # [warn] cmd

mkdir -p "test_dirs/abc"

# [warn] cmd (ecd :)
mkdir -p "test_dirs/99 🌸 Unicode fallback !%,^"
mkdir -p "test_dirs/99 🍀 Unicode fallback !%,^"
