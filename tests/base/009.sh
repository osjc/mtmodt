#Title: Program works if called using relative path

FindExecutable
Import "checks"

RootLocation=`dirname $MAINFILE`/..
ln -s $RootLocation root
ExpectedResourceLocation=`cd root/lua;pwd`
CheckProgramResourceSearch root/bin/mtmodt "$ExpectedResourceLocation"
