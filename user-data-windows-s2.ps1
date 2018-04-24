$name = "HNAME"
$lname = hostname

$string=$lname.split("{.}")
$hname = "$string.waterfrontmedia.net"

$TARGETDIR = "C:\scripts"
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}

$url = "http://10.133.105.19/kickstart/puppet-3.8.7-x64.msi"
$output = "C:\scripts\puppet-3.8.7-x64.msi"
$start_time = Get-Date
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
#Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

If ($name -Match "usnjdev" -Or $name -Match "usnjqa")
{
	$PServer = "usnjqa1lfm01.waterfrontmedia.net"
	If ($name -Match "usnjdev")
	{
		$Envir = "Dev"
		$ServerIP = "10.133.121.119"
	}
	ElseIf ($name -Match "usnjqa")
	{
		$Envir = "QA"
		$ServerIP = "10.133.122.154"
	}
}
ElseIf ($name -Match "usnjstg" -Or $name -Match "usnjw")
{
	$PServer = "usnjlpuppet01.waterfrontmedia.net"
	$ServerIP = "10.133.104.224"
	If ($name -Match "usnjstg" -Or $name -Match "usnjsw")
	{
		$Envir = "Stage"
	}
	ElseIf ($name -Match "usnjw")
	{
		$Envir = "Prod"
	}
}
ElseIf ($name -Match "awse")
{
	$PServer = "awselpuppet01.waterfrontmedia.net"
	$ServerIP = "172.31.90.195"
	If ($name -Match "awsestg" -Or $name -Match "awsesw")
	{
		$Envir = "Stage"
	}
	ElseIf ($name -Match "awsew")
	{
		$Envir = "Prod"
	}
}
Else
{
	$PServer = "usnjlpuppet01.waterfrontmedia.net"
	$ServerIP = "10.133.104.224"
	If ($name -Match "usnjstg" -Or $name -Match "usnjsw")
	{
		$Envir = "Stage"
	}
	ElseIf ($name -Match "usnjw")
	{
		$Envir = "Prod"
	}
}

If((Test-Path -Path "C:\scripts\puppet-3.8.7-x64.msi") -and !(Test-Path -Path "C:\Program Files\Puppet Labs")){
    msiexec /qn /norestart /i C:\scripts\puppet-3.8.7-x64.msi PUPPET_MASTER_SERVER=$PServer PUPPET_AGENT_CERTNAME=$name 
#PUPPET_AGENT_ENVIRONMENT=$Envir
}

$Matches = Select-String -Path C:\Windows\system32\drivers\etc\hosts -Pattern $ServerIP
$CC = $Matches.Matches.Count
If ( $CC -eq "0" )
{
	Add-Content C:\Windows\system32\drivers\etc\hosts "`n$ServerIP   $PServer"
}	

#Installing Require IIS and other modules
Import-Module ServerManager
Add-WindowsFeature FS-FileServer,AS-WAS-Support,MSMQ-Server,RSAT-Web-Server,Telnet-Client,WAS,SNMP-Services,SMTP-Server,NET-Framework
Add-WindowsFeature Web-Common-Http,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Includes,Web-Http-Logging,Web-Log-Libraries,Web-Request-Monitor,Web-Custom-Logging,Web-ODBC-Logging,Web-Basic-Auth,Web-Windows-Auth,Web-Digest-Auth,Web-Client-Auth,Web-Cert-Auth,Web-Url-Auth,Web-Url-Auth,Web-Stat-Compression,Web-Dyn-Compression,Web-IP-Security,Web-Filtering,Web-Mgmt-Tools,Web-Scripting-Tools,Web-Mgmt-Service,Web-Mgmt-Compat

c:/windows/system32/msiexec.exe /i C:\scripts\rewrite_2.0_rtw_x64.msi /qn
Start-Sleep -s 10 
c:/windows/system32/inetsrv/appcmd.exe set config -section:system.webServer/httpProtocol /+"customHeaders.[name='Server-ID',value='$lname']"
Start-Sleep -s 10
C:/Windows/Microsoft.NET/Framework/v4.0.30319/aspnet_regiis.exe -i
Start-Sleep -s 10
c:/windows/system32/msiexec.exe /i C:\scripts\AdvancedLogging64.msi /qn 


#OU=2008\+,OU=Production,OU=windows_servers,OU=Servers,DC=waterfrontmedia,DC=net
#get-adcomputer win7-c1 | Move-ADObject -TargetPath ‘ou=charlotte,dc=iammred,dc=net’

restart-computer -force
