# Default settings for parameters
class winbind::params {
  $krb5_admin_server                    = 'FILE:/var/log/kadmind.log'
if ( $::hostname =~ /^mpt/ )
  {
  $krb5_admin_server_name               = 'mptwdc01.waterfrontmedia.net'
  }
elsif ( $::hostname =~ /^wte/ )
  {
  $krb5_admin_server_name               = 'wtewdc01.waterfrontmedia.net'
  }  
elsif ( $::hostname =~ /^aws/ )
  {
  $krb5_admin_server_name               = 'awsewdc07.waterfrontmedia.net'
  }
   else {
  $krb5_admin_server_name               = 'usnjwdc04.waterfrontmedia.net'
   }
  $krb5_default                         = 'FILE:/var/log/krb5libs.log'
  $krb5_dns_lookup_kdc                  = true
  $krb5_dns_lookup_realm                = true
  $krb5_forwardable                     = true
  $krb5_kdc                             = 'FILE:/var/log/krb5kdc.log'
  $krb5_renew_lifetime                  = '7d'
  $krb5_ticket_lifetime                 = '24h'
  $oddjobd_homdir_mask                  = '0077'
  $pam_cached_login                     = 'yes'
  $pam_debug                            = 'no'
  $pam_debug_state                      = 'no'
  $pam_krb5_auth                        = 'no'
  $pam_krb5_ccache_type                 = ''
  $pam_mkhomedir                        = 'no'
  $pam_require_membership_of            = ['',]
  $pam_silent                           = 'no'
  $pam_warn_pwd_expire                  = 14
  $smb_encrypt_passwords                = 'yes'
  $smb_idmap_config_default_backend     = 'rid'
  $smb_idmap_config_default_range_end   = 50000
  $smb_idmap_config_default_base_rid    = 0
  $smb_idmap_config_default_range_start = 10000
  $smb_idmap_config_default_rangesize   = 10000 
  $smb_log_file                         = '/var/log/samba/%m'
  $smb_log_level                        = 0
  $smb_max_log_size                     = 0
  $smb_printcap_name                    = 'cups'
  $smb_printing                         = 'cups'
  $smb_realm                            = 'WATERFRONTMEDIA.NET'
  $smb_security                         = 'ads'
  $smb_passdb_backend                   = 'tdbsam'
  $smb_netbios_name                     = $::hostname
  $smb_server_string_ver                = 'Samba Server Version %v'
  $smb_syslog                           = 0
  $smb_template_homedir                 = '/home/%D/%U'
  $smb_template_shell                   = '/bin/bash'
  $smb_winbind_enum_groups              = 'yes'
  $smb_winbind_enum_users               = 'yes'
  $smb_winbind_load_printers            = 'yes'
  $smb_winbind_cups_options             = 'raw'
  $smb_winbind_normalize_names          = 'no'
  $smb_winbind_nss_info                 = 'rfc2307'
  $smb_winbind_offline_logon            = true
  $smb_winbind_separator                = '+'
  $smb_winbind_use_default_domain       = true
  $smb_workgroup                        = 'WATERFRONTMEDIA'

}
