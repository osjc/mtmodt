--Title: Loading cyclic library dependency directly

LoadLibrary "fakeexit"
CheckLibraryLoadFailure("lib02",{"lib02","lib01","lib03"},{})
