if _VERSION ~= "Lua 5.1" then
  PrintErr "This program requires LUA 5.1 because Minetest runs its mods and"
  PrintErr "subgames using this exact version of Lua and therefore the"
  PrintErr "results of testing the mods/subgames would not be relevant if a"
  PrintErr "different version of Lua is used to run the tests."
  PrintErr ("Version of Lua found: ".._VERSION)
  os.exit(1)
end
