<powershell>
$name="HNAME"
$string=$name.split("{.}")
$hname = $string[0]
$computerName = Get-WmiObject Win32_ComputerSystem
Write-host "Current Computer Name is " $hname
$computername.Rename($hname)

$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration |where{$_.IPEnabled -eq "TRUE"}
  Foreach($NIC in $NICs) {
  $DNSServers = "172.31.22.107","10.133.105.37"
  $NIC.SetDNSServerSearchOrder($DNSServers)
  $NIC.SetDynamicDNSRegistration("TRUE")
}

C:\Windows\System32\tzutil.exe /s "Eastern Standard Time"

w32tm /config /manualpeerlist:172.31.22.107 /syncfromflags:MANUAL
Stop-Service w32time
Start-Service w32time

w32tm /resync

$url = "http://10.133.105.101/kickstart/puppet-3.8.7-x64.msi"
$output = "C:\scripts\puppet-3.8.7-x64.msi"
$start_time = Get-Date
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

msiexec /qn /norestart /i C:\scripts\puppet-3.8.7-x64.msi PUPPET_MASTER_SERVER=awselpuppet01.waterfrontmedia.net PUPPET_AGENT_CERTNAME=$name

Add-Content C:\Windows\system32\drivers\etc\hosts "`n172.31.90.195 awselpuppet01.waterfrontmedia.net"

restart-computer -force
</powershell>