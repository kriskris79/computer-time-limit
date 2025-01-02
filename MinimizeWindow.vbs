Set objShell = CreateObject("WScript.Shell")
strUserProfile = objShell.ExpandEnvironmentStrings("%UserProfile%")
objShell.Run "cmd /c " & strUserProfile & "\Documents\DailyUsageLimit.bat", 2, False
