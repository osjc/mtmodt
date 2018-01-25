local OriginalStdOut = io.stdout
io.stdout = nil
local OriginalStdErr = io.stderr
io.stderr = nil
local OriginalWrite = OriginalStdOut.write

function WriteStdOut(Text)
  OriginalWrite(OriginalStdOut, Text)
end

function WriteStdErr(Text)
  OriginalWrite(OriginalStdErr, Text)
end

local function PrintCore(WriteProc, Text)
  WriteProc(Text)
  WriteProc("\n")
end

function print(What)
  PrintCore(WriteStdOut,What)
end

function PrintErr(What)
  PrintCore(WriteStdErr,What)
end
