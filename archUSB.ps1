[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Changes default TLS 1.0 to TLS 1.2
Invoke-WebRequest https://github.com/yuk7/ArchWSL/releases/download/18081100/Arch.zip -OutFile archWSL.zip
$currentShell = New-Object -Com shell.application

$zip = $currentShell.NameSpace("$pwd\archWSL.zip")
foreach($file in $zip.items()) 
{
	$currentShell.Namespace("$pwd").copyHere($file)
}
.\Arch