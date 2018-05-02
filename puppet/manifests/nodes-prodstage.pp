node /^usnjlweb\d+$/ , /^usnjelk\d+$/ , /^usnjlarmail\d+$/ , usnjbatch1-ag , /^usnjlapp\d+\-ag$/ , /^usnjlsearch\d+$/ , /^usnjlidss\d+$/ , /^usnjlbiapp\d+$/ , /^usnjstgcf8-\d+$/ , /^usnjstgladmin\d+$/ , /^usnjstglcouch\d+$/ , /^usnjstglsearch\d+$/, /^usnjstglsg\d+$/, /^usnjstglweb\d+$/ , /^usnjstglabsg\d+$/ , /^usnjlvcache1\d+$/ , /^usnjstglvcache\d+$/ , /^usnjstglvc\d+$/ inherits default {
   
}


## Everday Health AWS Section
node /^awsweh\d+\.[a-zA-Z0-9]+\.[a-zA-Z0-9]+/, /^awseweh\d+\.[a-zA-Z0-9]+\.[a-zA-Z0-9]+/ {
  include hostfile::eh_platform
  include hostfile::eh_platform_localcmsdb
  include hostfile::eh_platform_primarydb
  include eh-iis
  #include win-base
}

## Everyday Health AWS SQL Section
node /^awswsql\d+\.[a-zA-Z0-9]+\.[a-zA-Z0-9]+/,/^awsewsql\d+\.[a-zA-Z0-9]+\.[a-zA-Z0-9]+/ {
  include win-base
}

## Testing Section
node 'usnjlmon03.waterfrontmedia.net', 'usnjlweb61.waterfrontmedia.net', /^usnjlmta\d+$/, 'usnjlcms02.waterfrontmedia.net' {
  #include base
  #include winbind
  class
  { 'spacewalk':
       spacewalk_env => 'prod',
  }
  
}


node '10.133.105.110','usnjlmonitor01.waterfrontmedia.net' {
  include base
  include winbind
  include nagios::client
  include nagios::server
  include spacewalk
}



node usnjlror04, usnjlbiapp02, usnjlvsftp03 , usnjlvac01 {
    include base
    include winbind
    class
    { 'spacewalk':
        spacewalk_env => 'prod',
    }
   include eh-ssh::banner
}

node /^usnjlcouchbase\d+$/ , /^usnjlror\d+$/, /^usnjlsphinx\d+$/, /^usnjlcms\d+$/ , /^usnjlutil\d+$/ ,/^usnjstgldb02+$/ {
        include eh-ssh::banner
    class
    { 'spacewalk':
        spacewalk_env => 'prod',
    }

}

node /^usnjldb\d+$/
{
    #class
    #{ 'spacewalk':
    #    spacewalk_env => 'prod',
    #}
   include eh-ssh::banner
}
