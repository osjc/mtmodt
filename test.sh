#!/bin/bash

set -eu

function SplitIt()
{
  ItemName=${1-n/a}
  ItemExt=${2-n/a}
}

function ExecuteShellTest()
{
  echo "rm -rf testcase.tmp" >testcase.tmp
  echo "LocationHere=$LocationHere" >>testcase.tmp
  echo 'export PATH="'"$StateBase"'/bin"' >>testcase.tmp
  echo "export LUA=$LUA" >>testcase.tmp
  echo ". $LocationHere/tests/frmwork.shi" >>testcase.tmp
  echo ". $1 >output.log 2>error.log" >>testcase.tmp
  if bash -eu testcase.tmp; then
    Result="PASS"
  else
    Result="FAIL"
  fi
}

function ExecuteLuaTest()
{
  MainDir="$LocationHere/lua"
  echo 'LibDir = "'"$LocationHere/tests/"'"' >testcase.lua
  echo 'MainDir = "'"$MainDir/"'"' >>testcase.lua
  echo 'dofile(LibDir.."'"frmwork.lua"'")' >>testcase.lua
  echo 'dofile("'"$MainDir/init.lua"'")' >>testcase.lua
  echo 'dofile "'"$1"'"' >>testcase.lua
  Result="FAIL"
  if $LUA testcase.lua >output.log 2>error.log; then
    Result="PASS"
  fi
}

function InvalidMetaData()
{
  echo "Invalid metadata line ($1):" >>error.log
  echo "[$Line]" >>error.log
  MetaDataInvalid=true
}

function CheckMetaDataUnique()
{
  if test "$1" != "x"; then
    InvalidMetaData "Multiple $2 metadata lines"
  fi
}

function CheckMetaDataPresent()
{
  if test "$1" = "x"; then
    echo "Missing $2 metadata line" >>error.log
    MetaDataInvalid=true
  fi
}

function ReadTestCaseMetaData()
{
  local Ch Name Len NameLen Index ValueStart Value

  MetaTitle=""
  exec <$1
  Len=${#2}
  MetaDataInvalid=false
  MetaTitle=""
  while read Line; do
    if test "x$Line" = "x"; then
      break
    fi
    Ch=${Line:0:$Len}
    if test "x$Ch" != "x$2"; then
      InvalidMetaData 'does not start with "'$2'" '"[$Ch]"
      break
    fi
    Name="${Line:$Len}"
    Name="${Name%:*}"
    NameLen=${#Name}
    let Index=NameLen+Len
    Ch=${Line:$Index:1}
    if test "x$Ch" != "x:"; then
      InvalidMetaData 'missing ":" after metadata item name '"[$Ch]"
      break
    fi
    ValueStart=NameLen+Len+1
    Value="${Line:$ValueStart}"
    Value=`echo $Value`
    if test "x$Value" = "x"; then
      InvalidMetaData "no value specified"
      break
    fi
    if test "$Name" = "Title"; then
      CheckMetaDataUnique "x$MetaTitle" "title"
      MetaTitle="$Value"
    fi
    if $MetaDataInvalid; then
      break
    fi
  done
  CheckMetaDataPresent "x$MetaTitle" "title"
}

function InitializeStats()
{
  CountInvalidSections=0
  CountMissingSections=0
  CountNotFound=0
  CountTotal=0
  CountPass=0
  CountFail=0
  CountBadMetaData=0
}

function FindProgramLocation()
{
  LocationHere=`dirname $0`
  LocationHere=`cd $LocationHere;pwd`
}

function CreateTestExecutionBase()
{
  if test "${TEMP-n/a}" = "n/a"; then
    TEMP=${TMP:/tmp}
  fi
  StateBase=$TEMP/testexec
  rm -rf $StateBase
  mkdir -p $StateBase
  cd $StateBase
  mkdir bin
  ProgList="
    base32 base64 basename cat chmod chksum comm cp csplit cut date dd df dir
    dircolors  dirname du echo env expand expr factor false fmt fold groups
    head hostid id install join link ln logname ls md5sum mkdir mkfifo mknod
    mktemp mv nice nl nohup nproc numfmt od paste pathchk pinky pr printenv
    printf ptx pwd readlink realpath rm rmdir runcon seq sha1sum sha224sum
    sha256sum sha384sum sha512sum shred shuf sleep sort split stat stdbuf
    stty sum sync tac tail tee test timeout touch tr true truncate tsort tty
    uname unexpand uniq unlink users vdir wc who whoami yes
    bash diff find xargs grep sed
  "
  List=""
  for Program in $ProgList; do
    for Dir in /bin /usr/bin; do
      ProgSpec=$Dir/$Program
      if test -x $ProgSpec; then
        List="$List $ProgSpec"
        break
      fi
    done
  done
  ln -s $List bin
}

function FindWorkingLua()
{
  cd $StateBase
  bash $LocationHere/bin/mtmodt --write-cfg >output.log 2>error.log || true
  if test -f config.shi; then :; else
    echo "---" >>output.log
    echo "---" >>error.log
    mtmodt --write-cfg >>output.log 2>>error.log || true
    if test -f config.shi; then :; else
      echo "Failed to locate working Lua"
      exit 1
    fi
  fi
  . ./config.shi
}

function RunListedTestCases()
{
  StripSectionNameFromTestName=$1
  for TestCase in $List; do
    cd $LocationHere/tests
    TempIfs="$IFS"
    IFS="."
    SplitIt $TestCase
    IFS=$TempIfs
    if $StripSectionNameFromTestName; then
      ItemNameStr=${ItemName#*/}
    else
      ItemNameStr="$ItemName"
      while test ${#ItemNameStr} != "12"; do
        ItemNameStr="$ItemNameStr "
      done
    fi
    if test "$ItemExt" = "sh"; then
      ItemExtStr="SH "
      TestExec="ExecuteShellTest"
      MetaPrefix="#"
    elif test "$ItemExt" = "lua"; then
      ItemExtStr="LUA"
      TestExec="ExecuteLuaTest"
      MetaPrefix="--"
    else
      continue
    fi
    TestCaseSpec=$LocationHere/tests/$TestCase
    let CountTotal=CountTotal+1
    echo -n "      $ItemExtStr $ItemNameStr  "
    TestExecSpec=$StateBase/$ItemName
    rm -rf $TestExecSpec
    mkdir -p $TestExecSpec
    cd $TestExecSpec
    ReadTestCaseMetaData "$TestCaseSpec" "$MetaPrefix"
    if $MetaDataInvalid; then
      echo $'\r'"META"
      let CountBadMetaData=CountBadMetaData+1
      continue
    fi
    echo -n "$MetaTitle"$'\r'
    unset TempIfs ItemName ItemExt
    if ${MainFileFound-false}; then
      unset MainFileFound MAINFILE
    fi
    $TestExec $TestCaseSpec
    echo $Result
    if test "$Result" = "PASS"; then
      let CountPass=CountPass+1
      cd $LocationHere/tests
      rm -rf $TestExecSpec
    else
      let CountFail=CountFail+1
    fi
  done
}

function SplitLineIntoPieces()
{
  SectionName=$1
  shift
  SectionDescription=$@
}

function ScanIndexAndRunAllMentionedTestsInOrder()
{
  cd $LocationHere/tests
  TempListSpec=$StateBase/index.tmp
  ExpectedListSpec=$StateBase/index.exp
  ActualListSpec=$StateBase/index.act
  DiffSpec=$StateBase/index.dif
  rm -f $TempListSpec
  for Dir in *; do
    if test -d $Dir; then
      echo $Dir >>$TempListSpec
    fi
  done
  sort $TempListSpec >$ExpectedListSpec
  IsNotFirstSection=false
  exec 8<index.txt
  rm -f $TempListSpec
  while read Line <&8; do
    Line=`echo $Line`
    if test "x$Line" = "x"; then
      continue
    fi
    if test "${Line:0:1}" = "#"; then
      continue
    fi
    SplitLineIntoPieces $Line
    if $IsNotFirstSection; then
      echo
    else
      IsNotFirstSection=true
    fi
    cd $LocationHere/tests
    if test -d $SectionName; then :; else
      echo 'ERROR: Invalid section "'"$SectionName"'"'
      let CountInvalidSections=CountInvalidSections+1
      continue
    fi
    echo "Section: $SectionName ($SectionDescription)"
    echo $SectionName >>$TempListSpec
    echo 
    List=`echo $SectionName/*`
    OriginalCountTotal=$CountTotal
    OriginalCountPass=$CountPass
    RunListedTestCases true
    let ExpectedCountPass=OriginalCountPass+CountTotal-OriginalCountTotal
    if test "$CountPass" = "$ExpectedCountPass"; then
      rmdir "$StateBase/$SectionName"
    fi
  done
  sort $TempListSpec >$ActualListSpec
  if diff -u $ExpectedListSpec $ActualListSpec >$DiffSpec; then :; else
    echo
    exec 8<$DiffSpec
    SkipLines=3
    while read Line <&8; do
      if test "$SkipLines" != "0"; then
        let SkipLines=SkipLines-1 || true
        continue
      fi
      Ch=${Line:0:1}
      if test "$Ch" = "-"; then
        SectionName=${Line:1}
        echo 'ERROR: Missing section "'"$SectionName"'"'
        let CountMissingSections=CountMissingSections+1
      fi
    done
  fi
}

function DetermineWhatToExecuteAndDoIt()
{
  cd $LocationHere/tests
  if test "${1-n/a}" = "n/a"; then
    ScanIndexAndRunAllMentionedTestsInOrder
    echo
    echo "Summary:"
  else
    List=""
    while true; do
      Item="x"
      if test -f $1; then
        Item="$1"
      elif test -f $1.sh; then
        Item="$1.sh"
      elif test -f ${1-n/a}.lua; then
        Item="$1.lua"
      else
        echo "ERROR: Test not found: $1"
        let CountTotal=CountTotal+1
        let CountNotFound=CountNotFound+1
      fi
      if test "$Item" != "x"; then
        List="$List $Item"
      fi
      shift
      if test "${1-n/a}" = "n/a"; then
        break
      fi
    done
    if test "x$List" != "x"; then
      RunListedTestCases false
    fi
  fi
}

function AddNewLineIfNeeded()
{
  if ${NewLineNeeded-true}; then
    echo
    NewLineNeeded=false
  fi
}

function ShowStatistics()
{
  Failed=false
  if test "$CountMissingSections" != "0"; then
    AddNewLineIfNeeded
    echo "Missing sections: $CountMissingSections"
    Failed=true
  fi
  if test "$CountInvalidSections" != "0"; then
    AddNewLineIfNeeded
    echo "Invalid sections: $CountInvalidSections"
    Failed=true
  fi
  if test "$CountTotal" = "0"; then
    echo "No tests were executed"
    Failed=true
  else
    AddNewLineIfNeeded
    if test "$CountTotal" = "$CountPass"; then
      echo "All $CountTotal tests passed"
    else
      echo "Total tests: $CountTotal"
      if test "$CountNotFound" != "0"; then
        echo "Tests missed: $CountNotFound"
      fi
      if test "$CountPass" != "0"; then
        echo "Passed tests: $CountPass"
      fi
      if test "$CountBadMetaData" != "0"; then
        echo "Bad metadata: $CountBadMetaData"
      fi
      if test "$CountFail" != "0"; then
        echo "Failed tests: $CountFail"
      fi
    fi
    if test "$CountTotal" != "$CountPass"; then
      Failed=true
    fi
  fi
  if $Failed; then
    exit 1
  else
    rm -rf $StateBase
  fi
}

InitializeStats
FindProgramLocation
CreateTestExecutionBase
FindWorkingLua
DetermineWhatToExecuteAndDoIt "$@"
ShowStatistics
