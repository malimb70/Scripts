node 'usnjdevlutil02.waterfrontmedia.net',
     'usnjdev16-ag.waterfrontmedia.net',
     'usnjdev9-ag.waterfrontmedia.net',
     'usnjdevcf8-02.waterfrontmedia.net',
     'usnjdevforums.waterfrontmedia.net',
     'usnjdevlcask01.waterfrontmedia.net',
     'usnjdevlcouch01.waterfrontmedia.net',
     'usnjdevror01.waterfrontmedia.net',
     'usnjdevsphinx01.waterfrontmedia.net',
     'usnjdevwpress02.waterfrontmedia.net',
     'usnjdevldb01.waterfrontmedia.net',
     'usnjlbuild01.waterfrontmedia.net',
     'usnjlsvn02.waterfrontmedia.net',
     'usnjqa1swtst01.waterfrontmedia.net',
    'usnjqa1drugs01.waterfrontmedia.net',
    'usnjqa1cf8-02.waterfrontmedia.net',
    'usnjqa1forums.waterfrontmedia.net',
    'usnjqa1forums02.waterfrontmedia.net',
    'usnjqa1idss01.waterfrontmedia.net',
    'usnjqa1ldb01.waterfrontmedia.net',
    'usnjqa1lmta01.waterfrontmedia.net',
    'usnjqa1lutil01.waterfrontmedia.net',
    'usnjqa1mon01.waterfrontmedia.net',
    'usnjqa1mptphp01.waterfrontmedia.net',
    'usnjqa1qa9-ag.waterfrontmedia.net',
    'usnjqa1ror01.waterfrontmedia.net',
    'usnjqa1sphinx01.waterfrontmedia.net',
    'usnjdevmptphp01.waterfrontmedia.net', 
    'usnjsvn01.waterfrontmedia.net',  
    'usnjdevlsg01.waterfrontmedia.net', 
    'usnjdevlsg02.waterfrontmedia.net', 
    'usnjqalsg01.waterfrontmedia.net', 
    'usnjqalsg02.waterfrontmedia.net',
    'usnjltestrail01.waterfrontmedia.net', 
    'usnjdevwpress01.waterfrontmedia.net', 
    'usnjdevlbtest01.waterfrontmedia.net',
    'usnjqa1elk01.waterfrontmedia.net', 
    'usnjbigljohn.waterfrontmedia.net',
    'usnjdevldb02.waterfrontmedia.net',
    'usnjqa1ldb02.waterfrontmedia.net',
    'usnjqa1vcache04.waterfrontmedia.net' inherits default{
  
}


## Everday Health AWS Section
node /^awsstgweh\d+\.[a-zA-Z0-9]+\.[a-zA-Z0-9]+/ {
  include hostfile::eh_platform
  include hostfile::eh_platform_localcmsdb
  include hostfile::eh_platform_primarydb
  include eh-iis
  #include win-base
}

## Everyday Health AWS SQL Section
node /^awsstgwsql\d+\.[a-zA-Z0-9]+\.[a-zA-Z0-9]+/ {
  include win-base
}

## Testing Section

node usnjqa1wpress01 inherits default {

   class  { 'eh-apache':
                pcre_ver => '8.37',
                    http_ver => '2.4.16' }
   class { 'eh-php':
             php_ver => '5.6.10'
        }
}

node /^usnjqa1lcouch\d+$/, /^usnjdevlcouch\d+$/, /^usnjdevvcache\d+$/, 'usnjqa1couch01' inherits default {
    
}

node usnjqa1wweb08
{
   include wintest
   include iis
   include hostfile::eh_aws_testing
}

node usnjqa1wptest01
{
   #include wintest
   #class { 'wintest':
   # myhash => {
   #     'testing1' =>
   #     {
   #             vdir_path => 'c:\websites\Testing\testing1',
   #             vdir_pool => 'testing1'
   #     },
   #     'testing2' =>
   #     {
   #             vdir_path => 'c:\websites\Testing\testing2',
   #             vdir_pool => 'testing2'
   #     },
   #     'testing3' =>
   #     {
   #             vdir_path => 'c:\websites\Testing\testing3',
   #             vdir_pool => 'testing3'
   #     },
   #  }
   #}
   #class { 'domain_membership':
   # join_options => '3',
   #}
   include hostfile::eh_aws_testing
   class { 'iis':
      pool_names => ['testing','testing1','testing2','testing3'],
      pool_ver => 'v4.0',
      site_name => 'Testing',
      site_path => 'c:\websites\Testing',
      site_port => '80',
      site_ip => '10.133.122.129',
      site_host => 'www.srinivasaraju.org',
      site_pool => 'testing',
      myhash => {
        'testing1' =>
        {
                vdir_sname => 'Testing',
                vdir_path => 'c:\websites\Testing\testing1',
                vdir_pool => 'testing1'
        },
        'testing2' =>
        {
                vdir_sname => 'Testing',
                vdir_path => 'c:\websites\Testing\testing2',
                vdir_pool => 'testing2'
        },
        'testing3' =>
        {
                vdir_sname => 'Testing',
                vdir_path => 'c:\websites\Testing\testing3',
                vdir_pool => 'testing3'
        },
     }
   }
}

node usnjqa1vcachetest01 inherits default {
        include users

}

## Everyday Health INSURANCE WEB Section
node usnjdevwwcast01 {
  include ins-iis
}
