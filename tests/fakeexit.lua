LoadLibrary "iocap"

ExpectedExitCode = 1

local function BuildReport(Expected,Actual)
  local Line = "---------"
  local ReportAboutExpected = Line.." Expected "..Line.."\n"..Expected
  local ReportAboutActual = Line.." Actual "..Line.."\n"..Actual
  return "\n"..ReportAboutExpected..ReportAboutActual..Line..Line
end

local OriginalExit = os.exit
os.exit = function(Code)
  NoMoreFakeExit()
  if Code == 0 then
    Fail "The program is not suppoed to terminate successfully"
  elseif Code ~= ExpectedExitCode then
    local Report = BuildReport(ExpectedExitCode, Code)
    Fail("The program returned the wrong exit code"..Report)
  else
    if ExpectedMessage then
      Message=GetCapturedStdErr()
      if ExpectedMessage ~= Message then
        local Report = BuildReport(ExpectedMessage, Message)
        Fail("The program emitted the wrong error message text"..Report)
      end
    end
    os.exit(0)
  end
end

function NoMoreFakeExit()
  os.exit=OriginalExit
end

function SetExpectedMessage(ExpectedStdErr)
  local MessageType=type(ExpectedStdErr)
  if MessageType == "table" then
    table.insert(ExpectedStdErr, "\n")
    ExpectedMessage = table.concat(ExpectedStdErr)
  elseif MessageType == "string" then
    ExpectedMessage = ExpectedStdErr.."\n"
  else
    Report = BuildReport("string or table", MessageType)
    Fail('Wrong type of argument "ExpectedStdErr"'..Report)
  end
  CaptureStdErr()
end

function CheckProgramFailure(ExpectedStdErr)
  SetExpectedMessage(ExpectedStdErr)
  LoadMain()
  Fail "The program terminated normally but it should not do that"
end

function CheckVersionFailure(Version)
  local ExpectedError={
    "This program requires LUA 5.1 because Minetest runs its mods and\n",
    "subgames using this exact version of Lua and therefore the\n",
    "results of testing the mods/subgames would not be relevant if a\n",
    "different version of Lua is used to run the tests.\n",
    "Version of Lua found: ",Version,
  }
  _VERSION=Version
  CheckProgramFailure(ExpectedError)
end

local function AddLink(Buffer, From, To, NewLine)
  if not NewLine then
    NewLine="\n"
  end
  local Link = 'Library "'..To..'" loaded from "'..From..'"'..NewLine
  table.insert(Buffer, Link)
end

local function AddChain(Buffer, Current, Chain, LastLink, NewLine)
  for Index,Library in ipairs(Chain) do
    if Current then
      AddLink(Buffer, Library, Current)
    end
    Current = Library
  end
  AddLink(Buffer, LastLink, Current, NewLine)
end

function CheckLibraryLoadFailure(LibName, Circle, Path)
  local CircilarLibrary = Circle[1]
  local Message = {}
  local HeaderText = "Circilar library dependencies detected"
  table.insert(Message, HeaderText..': "'..CircilarLibrary..'"\n')
  local Index,Library
  AddChain(Message, nil, Circle, CircilarLibrary)
  local IntermediaryText = "The chain was reached by the following path"
  table.insert(Message, IntermediaryText..":\n")
  AddChain(Message, CircilarLibrary, Path, "(main)", "")
  ExpectedExitCode = 101
  SetExpectedMessage(Message)
  LoadLibrary(LibName)
  Fail "A library with circular dependencies was loaded successfully"
end
