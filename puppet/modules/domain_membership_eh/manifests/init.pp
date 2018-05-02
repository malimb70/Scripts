class domain_membership_eh { 
  exec { 'join_domain':
    command  => "Set-ExecutionPolicy RemoteSigned -Force; C:\Sysprep\JoinDomain.ps1",
    unless   => "if((Get-WmiObject -Class Win32_ComputerSystem).domain -ne '${domain}'){ exit 1 }",
    provider => powershell,
    logoutput => true,
  }
}
