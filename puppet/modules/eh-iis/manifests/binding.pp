class eh-iis::binding {
  require eh-iis::website

  iis::manage_binding { 'platform.everydayhealth':
  site_name                  =>  'EverydayHealth_Platform',
  protocol                   =>  'http',
  port                       =>  '80',
  ip_address                 =>  $ipaddress,
  host_header                =>  'platform.everydayhealth.com'
  }
  iis::manage_binding { 'my-calorie-counter.com':
  site_name                  =>  'MyCalorieCounter',
  protocol                   =>  'http',
  port                       =>  '80',
  ip_address                 =>  $ipaddress,
  host_header                =>  'my-calorie-counter.com'
  }
  iis::manage_site {'Default Web Site':
    ensure                   =>  'absent'
  }
}
