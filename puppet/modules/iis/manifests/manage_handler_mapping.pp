define iis::manage_handler_mapping($handler_name = $title, $handler_type, $handler_path, $handler_verb, $handler_script, $module, $access, $site_name, $ensure = 'present') {
  validate_re($ensure, '^(present|installed|absent|purged)$', 'ensure must be one of \'present\', \'installed\', \'absent\', \'purged\'')
  
  $cmdSiteExists = "Test-Path \"IIS:\\Sites\\${site_name}\""
  $cmdHandlerExists = "Get-WebHandler -Name \"${handler_name}\" -PSPath \"IIS:\\Sites\\${site_name}\""
  
  if ($ensure in ['present','installed']) {
    exec { "Add-Handler-${title}}" :
      command   => "Import-Module WebAdministration; New-WebHandler -Name \"${handler_name}\" -Path \"${handler_path}\" -Verb \"${handler_verb}\" -Modules \"${module}\" -type \"${handler_type}\" -ScriptProcessor \"${handler_script}\" -PSPath \"IIS:\\Sites\\${site_name}\" -RequiredAccess \"${access}\"",
      unless    => "Import-Module WebAdministration; if((${$cmdHandlerExists}) -eq \$null) { exit 1 } else { exit 0 }",
      provider  => powershell,
      logoutput => true,
    }
  } else {
    exec { "Remove-Handler-${title}" :
      command   => "Import-Module WebAdministration; Remove-WebHandler -Name \"${handler_name}\" -PSPath \"IIS:\\Sites\\${site_name}\"",
      onlyif    => "Import-Module WebAdministration; if((${$cmdHandlerExists}) -eq \$null) { exit 1 } else { exit 0 }",
      provider  => powershell,
      logoutput => true,
    }
  }
}
