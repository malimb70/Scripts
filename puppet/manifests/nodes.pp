# nodes.pp
# Node specific configs here

node default {
    case $operatingsystem {
        RedHat, CentOS: {
		    include base
      		    include winbind
		    include eh-ssh::banner
		    include eh_domainjoin
	if (($ehenv == "prod") or ($ehenv == "stage")) {
  	class
  		{ 'spacewalk':
        	spacewalk_env => 'prod',
    	}
   	}
   else {
  	class
   	 	{ 'spacewalk':
    	    spacewalk_env => 'qa1',
    	}
   	}
     }
        FreeBSD: {

		}
	}
}	
