function CaptureStream(StreamName)
  print("Captured "..StreamName)
  local GetterName = "GetCapturedStd"..StreamName
  if _G[GetterName] then
    Fatal('Stream "Std'..StreamName..'" captured multiple times')
  end
  local Name = "WriteStd" ..StreamName
  local UncapturerName = "UncaptureStd"..StreamName
  local OriginalWrite = _G[Name]
  local Buffer = {}
  _G[Name] = function(What)
    OriginalWrite(What)
    table.insert(Buffer, What)
    for i=table.getn(Buffer)-1, 1, -1 do
      local StringBelow = Buffer[i]
      if string.len(StringBelow) > string.len(Buffer[i+1]) then
        break
      end
      Buffer[i] = StringBelow..table.remove(Buffer)
    end
  end
  _G[GetterName] = function()
    local Result = table.concat(Buffer)
    Buffer={}
    return Result
  end
end

function CaptureStdOut()
  CaptureStream("Out")
end

function CaptureStdErr()
  return CaptureStream("Err", "Err")
end
