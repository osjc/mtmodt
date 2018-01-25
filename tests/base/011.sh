#Title: Redirecting the LUA portion

Import "checks"

mkdir lua
echo 'print "Hello, world !"' >lua/main.lua
echo 'print(_VERSION)' >lua/init.lua
touch lua/init.lua
export MTMODTLUADIR=`pwd`/lua
mtmodt >output.txt
exec <output.txt
IFS=""
Expected=$'Lua 5.1'
CheckLine "init script output"
Expected=$'Hello, world !'
CheckLine "main script output"
