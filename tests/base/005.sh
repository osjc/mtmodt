#Title: Program correctly fails with missing lua

Import "checks"

unset LUA
CheckProgramFailure "mtmodt --write-cfg" "Lua is missing" "Lua not found"
