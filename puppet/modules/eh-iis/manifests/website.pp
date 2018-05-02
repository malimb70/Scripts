class eh-iis::website {
  require eh-iis::apppool

  iis::manage_site {'EverydayHealth_Platform':
    site_path                =>  'D:\WebSites\everydayhealth_platform',
    port                     =>  '80',
    ip_address               =>  $ipaddress,
    host_header              =>  'www.everydayhealth.com',
    app_pool                 =>  'EverydayHealth_Platform'
  }
  iis::manage_site {'MyCalorieCounter':
    site_path                =>  'D:\websites\My_Calorie_Counter',
    port                     =>  '80',
    ip_address               =>  $ipaddress,
    host_header              =>  'www.my-calorie-counter.com',
    app_pool                 =>  'MyCalorieCounter'
  }

}
