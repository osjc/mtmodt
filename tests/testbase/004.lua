--Title: Loading library with cyclic dependency

LoadLibrary "fakeexit"
CheckLibraryLoadFailure("lib05",{"lib01","lib03","lib02"},{"lib05"})
