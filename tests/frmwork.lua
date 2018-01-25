local LibraryLocation = LibDir
LibDir = nil
local MainLocation = MainDir
MainDir = nil
arg[0] = nil
local Libraries = {}
local CurrentlyLoading = "(main)"

local function ReportLibraryLoadChain(Library, ReferencingLibrary)
  local Current = Library
  while true do
    local LoadedFrom = '" loaded from "'..ReferencingLibrary..'"'
    PrintErr('Library "'..Library..LoadedFrom)
    if ReferencingLibrary == Current or ReferencingLibrary == "(main)" then
      break
    end
    Library = ReferencingLibrary
    ReferencingLibrary = Libraries[Library]
  end
end

local function ReportCircularDependency(Library)
  PrintErr('Circilar library dependencies detected: "'..Library..'"')
  ReportLibraryLoadChain(Library, CurrentlyLoading)
  PrintErr("The chain was reached by the following path:")
  local ReferencingLibrary = Libraries[Library]
  ReportLibraryLoadChain(Library, ReferencingLibrary)
  os.exit(101)
end

function LoadLibrary(Library)
  if not Libraries[Library] then
    Libraries[Library]=CurrentlyLoading
    local PreviouslyLoading=CurrentlyLoading
    CurrentlyLoading=Library
    dofile(LibraryLocation..Library..".lua")
    Libraries[Library]=true
    CurrentlyLoading=PreviouslyLoading
  elseif type(Libraries[Library]) == "string" then
    ReportCircularDependency(Library)
  end
end

function LoadMain()
  local MainFileSpec = MainLocation.."main.lua"
  if arg[0] == nil then
    arg[0] = MainFileSpec
  end
  dofile(MainFileSpec)
end

function Fatal(Message, Code)
  if Code == nil then
    Code = 150
  end
  PrintErr(Message)
  os.exit(Code)
end

function Fail(Message)
  if NoMoreFakeExit then
    NoMoreFakeExit()
  end
  Fatal(Message, 100)
end
