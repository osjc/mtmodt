#Title: Program works if symlinked

FindExecutable
Import "checks"

ln -s $MAINFILE .
ExpectedResourceLocation=`dirname $MAINFILE`
ExpectedResourceLocation=`cd $ExpectedResourceLocation/../lua;pwd`
CheckProgramResourceSearch ./mtmodt "$ExpectedResourceLocation"
