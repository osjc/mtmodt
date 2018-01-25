#Title: Program correctly fails with broken lua

Import "checks"

echo "false" >lua
chmod +x lua
export PATH=`pwd`:$PATH
unset LUA
CheckProgramFailure "mtmodt --write-cfg" "Lua is broken" "Lua not found"
