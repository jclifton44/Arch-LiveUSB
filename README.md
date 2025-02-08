# Arch Linux Install script
## Running Windows machine to get a LiveUSB
There are many ways to get your arch. The first one method of getting arch onto your machine is going to be through a pen drive. 
Simply insert your pen drive and run:
```
./makeArch.ps1
```
This assumes you are running a Windows environment. It will start a download of an arch ISO. Then it will mount the image, and copy the contents onto your formatted flash drive. This will only work if you are running on Windows with PowerShell. If you're execution policy disallows you from executing the script, change this with:
```
set-executionpolicy remotesigned
```
this will allow you to execute scripts in the power shell. To change this back afterwards run the following:
```
set-executionpolicy restricted
```

You may need to change the mirror on line 8 if at some point in time that url does not resolve.




