' Kawaii Todo Widget Launcher (Silent)
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

scriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
command = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptPath & "\launch.ps1"""
objShell.Run command, 0, False
