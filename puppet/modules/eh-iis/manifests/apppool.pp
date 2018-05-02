class eh-iis::apppool {  

  iis::manage_app_pool {'EverydayHealth_Platform':
    enable_32_bit            =>  false,
    managed_runtime_version  =>  'v4.0',
    managed_pipeline_mode    =>  'Integrated'
  }
  iis::manage_app_pool {'EverydayHealth_Platform_Drugs':
    enable_32_bit            =>  false,
    managed_runtime_version  =>  'v4.0',
    managed_pipeline_mode    =>  'Integrated'
  }
  iis::manage_app_pool {'EverydayHealth_Platform_Solutions':
    enable_32_bit            =>  false,
    managed_runtime_version  =>  'v4.0',
    managed_pipeline_mode    =>  'Integrated'
  }
  iis::manage_app_pool {'MyCalorieCounter':
    enable_32_bit            =>  false,
    managed_runtime_version  =>  'v4.0',
    managed_pipeline_mode    =>  'Integrated'
  }
  iis::manage_app_pool {'DefaultAppPool':
    ensure                   =>  'absent'
  }
  iis::manage_app_pool {'Classic .NET AppPool':
    ensure                   =>  'absent'
  }
  iis::manage_app_pool {'ASP.NET v4.0':
    ensure                   =>  'absent'
  }
  iis::manage_app_pool {'ASP.NET v4.0 Classic':
    ensure                   =>  'absent'
  }
}
