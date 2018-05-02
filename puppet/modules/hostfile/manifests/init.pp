class hostfile::eh_platform {
  host { 'MealPlannerPrimaryDB':
    name         =>  'MealPlannerPrimaryDB',
    ensure       =>  'present',
    comment      =>  "Database Server",
    ip           =>  '10.133.106.62',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'LuceneSearch':
    name         =>  'LuceneSearch',
    ensure       =>  'present',
    comment      =>  "Lucene VIP",
    ip           =>  '10.133.105.243',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'groups':
    name         =>  'groups.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "Database Server",
    ip           =>  '10.133.104.242',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'services':
    name         =>  'services.waterfrontmedia.com',
    ensure       =>  'present',
    comment      =>  "Services VIP",
    ip           =>  '10.133.105.241',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'Everydayhealth-Int':
    name         =>  'www.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "Everyday Health Internal VIP",
    ip           =>  '10.133.104.243',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'coreservice':
    name         =>  'coreservices.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "Core Services VIP",
    ip           =>  '10.133.104.148',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'Local Site':
    name         =>  'platform.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "Local EH Site",
    ip           =>  $ipaddress,
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
}

class hostfile::eh_platform_localcmsdb {
  if $ec2_placement_availability_zone == 'us-east-1a' {
    host { 'LocalCMSDB':
      name         =>  'LocalCMSDB',
      ensure       =>  'present',
      comment      =>  "LocalCMSDB",
      ip           =>  '172.31.104.4',
      target       =>  "C:\Windows\System32\drivers\etc\hosts",
      }
  }
  if $ec2_placement_availability_zone == 'us-east-1b' {
    host { 'LocalCMSDB':
      name         =>  'LocalCMSDB',
      ensure       =>  'present',
      comment      =>  "LocalCMSDB",
      ip           =>  '172.31.105.4',
      target       =>  "C:\Windows\System32\drivers\etc\hosts",
      }
  }
}

class hostfile::eh_platform_primarydb{
  if $ec2_placement_availability_zone == 'us-east-1a' {
    host { 'primarydb':
      name         =>  'primarydb',
      ensure       =>  'present',
      comment      =>  "primarydb",
      ip           =>  '10.133.106.62',
      target       =>  "C:\Windows\System32\drivers\etc\hosts",
      }
  }
  if $ec2_placement_availability_zone == 'us-east-1b' {
    host { 'primarydb':
      name         =>  'primarydb',
      ensure       =>  'present',
      comment      =>  "primarydb",
      ip           =>  '10.133.106.62',
      target       =>  "C:\Windows\System32\drivers\etc\hosts",
      }
  }
}

class hostfile::eh_platform_stg {
  host { 'MealPlannerPrimaryDB':
    name         =>  'MealPlannerPrimaryDB',
    ensure       =>  'present',
    comment      =>  "Database Server",
    ip           =>  '10.133.106.59',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'primarydb':
    name         =>  'primarydb',
    ensure       =>  'present',
    comment      =>  "Database Server",
    ip           =>  '10.133.106.59',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'LocalCMSDB':
    name         =>  'LocalCMSDB',
    ensure       =>  'present',
    comment      =>  "Database Server",
    ip           =>  '172.31.80.4',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'LuceneSearch':
    name         =>  'LuceneSearch',
    ensure       =>  'present',
    comment      =>  "Lucene VIP",
    ip           =>  '10.133.103.123',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'groups':
    name         =>  'groups.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "Database Server",
    ip           =>  '10.133.104.242',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'services':
    name         =>  'services.waterfrontmedia.com',
    ensure       =>  'present',
    comment      =>  "Services VIP",
    ip           =>  '10.133.105.65',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'services_eh':
    name         =>  'services.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "Services EH VIP",
    ip           =>  '10.133.105.66',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }  
  #host { 'Everydayhealth-Int':
  #  name         =>  'www.everydayhealth.com',
  #  ensure       =>  'present',
  #  comment      =>  "Everyday Health Internal VIP",
  #  ip           =>  '10.133.104.243',
  #  target       =>  "C:\Windows\System32\drivers\etc\hosts",
  #}
  host { 'coreservice':
    name         =>  'coreservices.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "Core Services VIP",
    ip           =>  '10.133.104.148',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'elmahviewer':
    name         =>  'elmahviewer.waterfrontmedia.net',
    ensure       =>  'present',
    comment      =>  "_STG_ELMAHViewer_VIP",
    ip           =>  '10.133.103.28',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'secure':
    name         =>  'secure.agoramedia.com',
    ensure       =>  'present',
    comment      =>  "_STG_Secure_VIP",
    ip           =>  '10.133.103.10',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'content':
    name         =>  'content.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "_STG_Content_VIP",
    ip           =>  '10.133.103.137',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }  
  host { 'Local Site Platform':
    name         =>  'platform.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "Local EH Site",
    ip           =>  $ipaddress,
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'Local Site':
    name         =>  'www.everydayhealth.com',
    ensure       =>  'present',
    comment      =>  "Local EH Site",
    ip           =>  $ipaddress,
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }
  host { 'cbstgclust':
    name         =>  'cbstgclust.waterfrontmedia.net',
    ensure       =>  'present',
    comment      =>  "CBSTG Clust",
    ip           =>  '10.133.103.21',
    target       =>  "C:\Windows\System32\drivers\etc\hosts",
  }  
}

#class hostfile::eh_platform_stg_dyn (
#$hostlist,
#){
#	define create_hosts_filevalues ($host_name,$host_ip,$host_comm) 
#	{
#		if $host_ip =~ /localhost/
#		{
#			$ipaddr = $ipaddress
#		}
#		else
#		{
#			$ipaddr = $host_ip
#		}
#		host { '$host_comm':
#			name         =>  $host_name,
#			ensure       =>  'present',
#			comment      =>  $host_comm,
#			ip           =>  $ipaddr,
#			target       =>  "C:\Windows\System32\drivers\etc\hosts",
#		}  
#	}
#
#	create_hosts(create_hosts_filevalues, $hostlist)
#}
