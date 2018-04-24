#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby

require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'

  intIP = "172.31.72.52"
  hname = "awsestglwpweb02"
  project = "mpt"
  role = "web"
  os = "linux"
  env = "stage"
        proj = project.upcase
        rol1 = role.downcase
        if ((hname =~ /awse/) && (env == "stage"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/awse_stage/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/awse_stage/"
        elsif ((hname =~ /awse/) && (env == "prod"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/awse_prod/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/awse_prod/"
        elsif ((hname =~ /usnj/) && (env == "stage"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/stage/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/stage/"
        elsif ((hname =~ /usnj/) && (env == "prod"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/prod/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/prod/"
        elsif ((hname =~ /usnj/) && (env == "dev"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/dev/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/dev/"
        elsif ((hname =~ /usnj/) && (env == "qa1"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/qa1/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/qa1/"
        elsif ((hname =~ /usnj/) && (env == "qa2"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/qa2/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/qa2/"
        else
            return "ERR"
        end

        cmd = "mkdir -p #{locpath}; svn co #{svnpath} #{locpath}"
        stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        str = stdout1.read
        rfile = "#{locpath}mpt_backends.vcl"
        
        cmd = "grep 'backend mpt_homepage' #{rfile} |cut -d' ' -f2|cut -d'{' -f1 |wc -l"
        bcc = `#{cmd}`.to_i
        bcc = bcc + 1
        if ( bcc < 10 )
          backend = "mpt_homepage_0#{bcc}"
        else
          backend = "mpt_homepage_#{bcc}"
        end
puts "#{backend}"
        str = "backend BNAME{\\n     .host = \"SERVERIP\";\\n     .port = \"80\"; \\n     .connect_timeout = 1.5s;\\n     .host_header = \"SITEURL\";\\n     .probe = {\\n         .url = \"/status.html\";\\n         .interval = 15s;\\n         .timeout = 180 s;\\n         .window = 5;\\n         .threshold = 5;\\n    }\\n}\\n\\n"

        str["BNAME"] = "#{backend}"
        str["SERVERIP"] = "#{intIP}"
        str["SITEURL"] = "staging.medpagetoday.com"

        if `grep '#{intIP}' #{rfile} |wc -l | xargs  |tr -d '\n'` == "0"
            cmd = "sed -i '/vcl_init/ i #{str}' #{rfile}"
            system(cmd)
            vinitstr="    mpt_homepage_dir.add_backend(BNAME, 1);"
            vinitstr["BNAME"] = "#{backend}"

            cmd = "sed -i 's/new mpt_homepage_dir.*/new mpt_homepage_dir = directors.hash();\\n     #{vinitstr}/g' #{rfile}"
            system (cmd)
            puts  "Backend is created"
        else
          puts "Backend already exist"            
        end

        

