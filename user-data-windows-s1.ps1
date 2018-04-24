#<powershell>

$TARGETDIR = "C:\scripts"
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}

$chname = hostname
$name = "HNAME"

echo "$chname -- $name" >> c:\scripts\ec2_logs

$string = $name.split("{.}")
$hname = $string[0]

If ($chname -ne $hname)
{
	$computerName = Get-WmiObject Win32_ComputerSystem
	Write-host "Current Computer Name is " $hname
	$computername.Rename($hname)
}

If ($name -Match "usnjdev" -Or $name -Match "usnjqa")
{
	$DNSServers = "10.133.125.11"
	$TServer = "10.133.125.11"
}
ElseIf ($name -Match "usnjstg" -Or $name -Match "usnjw")
{
	$DNSServers = "10.133.105.37","10.133.105.38"
	$TServer = "10.133.105.37"
}
ElseIf ($name -Match "awse")
{
	$DNSServers = "172.31.22.107","10.133.105.37"
	$TServer = "172.31.22.107"
}
Else
{
	$DNSServers = "10.133.105.37","10.133.105.38"
	$TServer = "10.133.105.37"
}

echo "Changed the hostname now -------" >> c:\scripts\ec2_logs

#$wmi = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"
#$wmi.EnableStatic("10.133.121.84", "255.255.255.0")
#$wmi.SetGateways("10.133.121.1", 1)
#$wmi.SetDNSServerSearchOrder($TServer)
	
$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration |where{$_.IPEnabled -eq "TRUE"}
  Foreach($NIC in $NICs) {
  $NIC.SetDNSServerSearchOrder($DNSServers)
  $NIC.SetDynamicDNSRegistration("TRUE")
}

echo "Changed the DNS Name now -------" >> c:\scripts\ec2_logs

C:\Windows\System32\tzutil.exe /s "Eastern Standard Time"

w32tm /config /manualpeerlist:$TServer /syncfromflags:MANUAL
Stop-Service w32time
Start-Service w32time
w32tm /resync

echo "Changed the Time now -------" >> c:\scripts\ec2_logs


restart-computer -force
#</powershell>