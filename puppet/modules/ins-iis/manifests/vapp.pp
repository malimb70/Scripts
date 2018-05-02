class ins-iis::vapp {
  require ins-iis::binding

  #Manage Virtual Apps
  iis::manage_virtual_application {'UserHealthProfileService':
    site_path                => 'D:\Websites\Healthdataservices\UserHealthProfileService',
    site_name                => 'Healthdataservices',
    app_pool                 => 'Healthdataservices'
  }
}
