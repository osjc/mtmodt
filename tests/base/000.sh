#Title: Getting the version information

FindExecutable

Import "checks"

function Extract()
{
  ItemName=${1-n/a}
  ItemValue=${2-n/a}
  ItemExtra=${3-n/a}
}

function CheckItemValue()
{
  local Length Ch

  Length=${#ItemValue}
  if test $Length -lt 2; then
    Fail "$1 too short: [$ItemValue]"
  fi
  Ch=${ItemValue:0:1}
  if test "$Ch" != '"'; then
    Fail "$1 does not start with a quote: [$ItemValue] [$Ch]"
  fi
  let Length=Length-1
  Ch=${ItemValue:$Length:1}
  if test "$Ch" != '"'; then
    Fail "$1 does not start with a quote: [$ItemValue] [$Ch]"
  fi
  let Length=Length-1
  ItemValue=${ItemValue:1:$Length}
}

mtmodt --version >version.txt

Version="n/a"
Years="n/a"
exec <$MAINFILE
while read Line; do
  TempIFS="$IFS"
  IFS="="
  Extract $Line
  IFS=$TempIFS
  echo "[$ItemName] [$ItemValue] [$ItemExtra]"
  if test "$ItemName" = "VERSION"; then
    CheckItemValue "Version" $Version
    Version=$ItemValue
  elif test "$ItemName" = "YEARS"; then
    CheckItemValue "Years" $Years
    Years=$ItemValue
  fi
done
if test "$Version" = "n/a"; then
  Fail "Version not found in the executable"
fi
if test "$Years" = "n/a"; then
  Fail "Copyright years not found in the executable"
fi
exec <version.txt
IFS=""
Expected="mtmodt - MineTest MOD Test - Version: $Version"
CheckLine "version"
Expected="Copyright (C) $Years Jozef Behran"
CheckLine "copyright"
