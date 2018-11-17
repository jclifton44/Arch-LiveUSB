#https://docs.microsoft.com/en-us/previous-versions/technet-magazine/jj554301(v=msdn.10)
param (
[string]$isopath = "C:\Users\Jeremy\Documents\archlinux-2018.10.01-x86_64.iso"
)
echo "Checking iso " $isopath

#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-6
if(Test-Path $isopath) {
	
} else {
	#https://docs.microsoft.com/en-us/powershell/module/bitstransfer/start-bitstransfer?view=win10-ps
	Start-BitsTransfer -Source http://mirror.rackspace.com/archlinux/iso/2018.10.01/archlinux-2018.10.01-x86_64.iso -Destination $isopath
}


#https://docs.microsoft.com/en-us/powershell/module/storage/mount-diskimage?view=win10-ps
$mounted = Mount-DiskImage -ImagePath $isopath -PassThru
$DriveLetter = ($mounted | Get-Volume).DriveLetter



$usb = Get-Disk | Where-Object BusType -eq USB | Clear-Disk -RemoveData -PassThru | New-Partition -UseMaximumSize -IsActive -AssignDriveLetter

#https://msdn.microsoft.com/en-us/library/1k6w8551.aspx 
if(!$usb)
{
	echo 'error: No USB inserted. Insert a USB storage device.'
	exit
}

echo $usb
$usbLetter = $usb.DriveLetter


$usb | Format-Volume -FileSystem FAT32



Copy-Item -Path "$($DriveLetter):\*" -Destination "$($usbLetter):" -Recurse -Verbose
Start-Sleep -Seconds 2
foreach($line in (Get-Content "$($DriveLetter):\LOADER\ENTRIES\ARCHISO_x86_64.CONF")){
	if($line -like "*archisolabel*"){
		foreach($attr in -split $line){
			if($attr -like "*archisolabel*"){
				$labelName = $attr -split '=' | Select -Index 1
			}
		}
	}
}
Dismount-DiskImage -ImagePath $isopath 


#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-content?view=powershell-6
label "$($usbLetter):"  $labelName