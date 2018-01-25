--Title: Capturing a stream multiple times

LoadLibrary "fakeexit"
LoadLibrary "iocap"
ExpectedExitCode = 150
SetExpectedMessage('Stream "StdErr" captured multiple times')
CaptureStdErr()
CaptureStdErr()
Fail "Attempt to capture StdErr twice was successful"
