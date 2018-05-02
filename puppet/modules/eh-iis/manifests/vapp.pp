class eh-iis::vapp {
  require eh-iis::binding

  #Manage Virtual Apps
  iis::manage_virtual_application {'drugs':
    site_path                => 'D:\websites\drugs',
    site_name                => 'EverydayHealth_Platform',
    app_pool                 => 'EverydayHealth_Platform_Drugs'
  }
  iis::manage_virtual_application {'solutions':
    site_path                => 'D:\websites\solutions',
    site_name                => 'EverydayHealth_Platform',
    app_pool                 => 'EverydayHealth_Platform_Solutions'
  }
}
