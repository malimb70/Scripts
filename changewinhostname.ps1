$name="awsewehweb01"
$computerName = Get-WmiObject Win32_ComputerSystem
Write-host "Current Computer Name is " $computerName
$computername.Rename($name)

$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration |where{$_.IPEnabled -eq “TRUE”}
  Foreach($NIC in $NICs) {
  $DNSServers = “172.31.22.107",”10.133.105.37"
  $NIC.SetDNSServerSearchOrder($DNSServers)
  $NIC.SetDynamicDNSRegistration(“TRUE”)
}

C:\Windows\System32\tzutil.exe /s "Eastern Standard Time"

w32tm /config /manualpeerlist:172.31.22.107 /syncfromflags:MANUAL
Stop-Service w32time
Start-Service w32time

w32tm /resync

#restart-computer -force