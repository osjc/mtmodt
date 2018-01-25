#Title: Correct error on wrong Lua version

Import "checks"

LuaVer="Lua 5.3"
Prog='_VERSION="'"$LuaVer"'"'
echo "$LUA -e '$Prog' "'"$@"' >lua
chmod +x lua
export PATH=`pwd`:$PATH
unset LUA
EOL=$'\n'
Error="This program requires LUA 5.1 because Minetest runs its mods and"
Error="$Error${EOL}subgames using this exact version of Lua and therefore"
Error="$Error the${EOL}results of testing the mods/subgames would not be"
Error="$Error relevant if a${EOL}different version of Lua is used to run"
Error="$Error the tests.${EOL}Version of Lua found: $LuaVer"
CheckProgramFailure mtmodt "Lua has wrong version" "$Error"
