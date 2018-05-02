class eh-iis::install{
  windowsfeature {'IIS':
    feature_name  =>  [
      ## Install IIS
      'Web-Server',
      ## Web Server
      'Web-WebServer',
      ## Common HTTP Features
      'Web-Common-Http',
      'Web-Static-Content',
      'Web-Default-Doc',
      'Web-Dir-Browsing',
      'Web-Http-Errors',
      'Web-Http-Redirect',
      ## Application Development
      'Web-App-Dev',
      'Web-Asp-Net',
      'Web-Net-Ext',
      'Web-ASP',
      'Web-CGI',
      'Web-ISAPI-Ext',
      'Web-ISAPI-Filter',
      ## Health and Diagnostics
      'Web-Health',
      'Web-Http-Logging',
      ## Security
      'Web-Security',
      'Web-Basic-Auth',
      'Web-Windows-Auth',
      'Web-Digest-Auth',
      'Web-Filtering',
      ## Management Tools
      'Web-Mgmt-Tools',
      'Web-Mgmt-Console',
    ]
  }
  windowsfeature { 'FS-FileServer':
    restart  =>  true
  }
  windowsfeature { 'File-Services':
    restart  =>  true
  }
  windowsfeature { 'NET-Framework':
    restart  =>  true
  }
  windowsfeature { 'NET-Framework-Core':
    restart  =>  true
  }
  windowsfeature { 'RSAT':
    restart  =>  true
  }
  windowsfeature { 'RSAT-Web-Server':
    restart  =>  true
  }
  windowsfeature { 'RSAT-Role-Tools':
    restart  =>  true
  }
  windowsfeature { 'SNMP-Service':
    restart  =>  true
  }
  windowsfeature { 'SNMP-Services':
    restart  =>  true
  }
  windowsfeature { 'Telnet-Client':
    restart  =>  true
  }
  windowsfeature { 'PowerShell-ISE':
    restart  =>  true
  }

#  package { 'Microsoft .NET Framework 4 Client Profile':
#    ensure           =>  installed,
#    source           =>  "C:\SysPrep\Executables\AspNetMVC4Setup.exe", 
#    install_options  =>  ['/q'],
#  }
#  package { 'Microsoft .NET Framework 4 Extended':
#    ensure           =>  installed,
#    source           =>  "C:\SysPrep\Executables\AspNetMVC4Setup.exe", 
#    install_options  =>  ['/q'],
#  } 
  package { 'Microsoft ASP.NET MVC 4':
    ensure           =>  installed,
    source           =>  "C:\SysPrep\Executables\dotNetFx40_Full_x86_x64.exe",
    install_options  =>  ['/q'],
  }
}
