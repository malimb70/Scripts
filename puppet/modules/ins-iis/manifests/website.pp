class ins-iis::website {
  require ins-iis::apppool

  iis::manage_site {'Healthdataservices':
    site_path                =>  'D:\Websites\Healthdataservices',
    port                     =>  '443',
    ip_address               =>  $ipaddress,
    host_header              =>  'healthdataservices.everydayhealth.com',
    app_pool                 =>  'Healthdataservices'
  }
  iis::manage_site {'Default Web Site':
    ensure                   =>  'absent'
  }

}
