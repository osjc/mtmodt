#Title: Program correctly fails if resources are missing

FindExecutable
Import "checks"

cp $MAINFILE .
Error="Lua portion of the program not found"
CheckProgramFailure "./mtmodt --write-cfg" "resources are missing" "$Error"
