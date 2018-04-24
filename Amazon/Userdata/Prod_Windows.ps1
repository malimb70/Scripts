<powershell>
Get-Content C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf | ForEach-Object {$_ -replace "usnjqa1lfm01", "usnjlpuppet01"} | Set-Content C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf.tmp
Remove-Item C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf
Rename-Item C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf.tmp C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf
</powershell>
