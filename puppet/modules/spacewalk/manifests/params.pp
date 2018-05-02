class spacewalk::params {
  case $::operatingsystem {
    'CentOS' : {
      case $::architecture
      {
        'x86_64':{
      	 case $::operatingsystemrelease {
      	   /^5/ : {
      			 $spacewalk_chan_key="1-centos-5-x64-key"
      			 $spacewalk_repo="http://yum.spacewalkproject.org/latest-client/RHEL/5/x86_64/spacewalk-client-repo-2.6-0.el5.noarch.rpm"
      			 $epel_repo="http://dl.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm"		
      			}
            #/^6.7/: 
			#{
            #  $spacewalk_chan_key="1-centos-67-x64-key"
            #  $spacewalk_repo="http://yum.spacewalkproject.org/latest-client/RHEL/6/x86_64/spacewalk-client-repo-2.6-0.el6.noarch.rpm"
            #  $epel_repo="http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm"
            #}
      		/^6/: 
			{
				$spacewalk_chan_key="1-centos-6-x64-key"
				$spacewalk_repo="http://yum.spacewalkproject.org/latest-client/RHEL/6/x86_64/spacewalk-client-repo-2.6-0.el6.noarch.rpm"
      			$epel_repo="http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm"		
      			}
            /^7.2/: 
			{
				$spacewalk_chan_key="1-centos-7-x64-key"
				$spacewalk_repo="http://yum.spacewalkproject.org/latest-client/RHEL/7/x86_64/spacewalk-client-repo-2.6-0.el7.noarch.rpm"
				$epel_repo="http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
            } 
            /^7/: {
				$spacewalk_chan_key="1-centos-7-x64-key"
				$spacewalk_repo="http://yum.spacewalkproject.org/latest-client/RHEL/7/x86_64/spacewalk-client-repo-2.6-0.el7.noarch.rpm"
				$epel_repo="http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
				}         
			}
		}      	
	    'i386':{
      	  case $::operatingsystemrelease {
      		/^5/ : {
      			    $spacewalk_chan_key="1-centos-5-32bit-key"
      				$spacewalk_repo="http://yum.spacewalkproject.org/latest-client/RHEL/5/i386/spacewalk-client-repo-2.6-0.el5.noarch.rpm"
      				$epel_repo="http://dl.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm"		
      			}
            #/^6.7/: {
            #  $spacewalk_chan_key="1-centos-6-32bit-key"
            #  $spacewalk_repo="http://yum.spacewalkproject.org/latest-client/RHEL/6/i386/spacewalk-client-repo-2.6-0.el6.noarch.rpm"
            #  $epel_repo="http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm"
            #}
      		/^6/ : {
      			    $spacewalk_chan_key="1-centos-6-32bit-key"
					$spacewalk_repo="http://yum.spacewalkproject.org/latest-client/RHEL/6/i386/spacewalk-client-repo-2.6-0.el6.noarch.rpm"
      				$epel_repo="http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm"		
      			}
      		}	
      	}
      }
    }
  }
}
