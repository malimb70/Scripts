#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby

require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'
require "./ehAWSAutomationClass"

options = {
  :task => 'task',
  :intname => 'intname',
	:zone => 'zone',
  :project => 'project',
  :role => 'role',
  :os => "os",
  :size => "size",
  :ami => "ami",
  :env => 'env',
  :optinfo => false
}

dis=""
parser = OptionParser.new do |opts|
  opts.banner = "Usage: awsEHClitool.rb -t task -i instance_id -z zone [options] "

  opts.on('-t', '--task=MANDATORY', "Need to pass info/status/stop/start/list") do |p|
		options[:task] = p
  end

  opts.on('-i', '--intname', "Pass Instance Name") do |p|
		options[:intname] = p
  end

  opts.on('-p', '--project', "Pass Project Name [MPT/WTE/EH/WP]") do |p|
    options[:project] = p
  end

  opts.on('-r', '--role', "Pass Role of Instanace [web/app/cf/db/varnish]") do |p|
    options[:role] = p
  end

  opts.on('-e', '--env', "Pass Environment [stage/prod]") do |p|
    options[:env] = p
  end

  opts.on('-o', '--os', "Pass OS [Windows/Linux]") do |p|
    options[:os] = p
  end

  opts.on('-s', '--size', "Pass Instanace Size") do |p|
    options[:size] = p
  end

  opts.on('-m', '--ami', "Pass AMI images") do |p|
    options[:ami] = p
  end

  opts.on('-z', '--zone', "Pass Zone of AWS") do |z|
		options[:zone] = z
  end

  opts.on('-g', '--optinfo', "Options for showing cluster storage and hosts details") do |o|
		options[:optinfo] = o
	end
		
	opts.on_tail("-h", "--help", <<__USAGE__) do
Show this message

Examples:
  ehAWSAutoScript.rb --task [create/start/stop/info/list] --intname [instancename] --project [mpt/eh/wte/wordpress] --role [web/db/app/cf] --os [windows/linux] --env [stage/prod] --zone [us-east-1] --optinfo 
  ehAWSAutoScript.rb -t [create/start/stop/info/list] --i [instancename] --p [mpt/eh/wte/wordpress] --r [web/db/app/cf] --o [windows/linux] --e [stage/prod] --z [us-east-1] -g 
  ehAWSAutoScript.rb --task create --project mpt --role web --os windows --env prod --optinfo 3 [It will created 3 new instances for mpt homepage servers]
  ehAWSAutoScript.rb --task list [It display all avilable instanace]
  ehAWSAutoScript.rb  -t start -i instance_id 
  ehAWSAutoScript.rb  -t stop -i instance_id
  
__USAGE__
    puts opts
    exit
    end  	
end

parser.parse!

eh = EHAWSAutomationClass.new
sshkey="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA48nlR2OEFvjo8pEA30p2rMiVRSW+uhp+NxeDRxQ+hjy9HV0bARq2EK3dSklsri2SkiTJ6BW7oAsuixjgH2EnY+rUjvSd+4/EoIk2O/CJbbeo/o9hHJT9s5dxqh10a05lpwTkLMOeF0kfkhQCYyObAg1oWGRZXDPpOo2dzRcoMCWY9X/3CEEZ3UAioW5IGQ0A3pQ99NuJFxCaKWu3NDQY6AOlfbuPLMlwdPEAhD6lw+kRBkYBfgjzDAQ37dhSdD+MD041j2uaTu1E8Oel4CWUNVxaxsLvY9OfsY81bzLWYy6pGLSIn+1ErzqYGjYunzAW/icsPoYsP4hAWYacZ7Ln+w== sraju@awselpuppet01"
# Get current date.
current = DateTime.now
cdate = "#{current.month}-#{current.day}-#{current.year}-#{current.hour}:#{current.min}"
cdate.chomp
puts " ---- Starting #{cdate} --------"
if options[:zone] == true 
    options[:zone] = ARGV[1]
end
if options[:project] == true 
    options[:project] = ARGV[0]
end
if options[:role] == true 
    options[:role] = ARGV[1]
end
if options[:os] == true 
    options[:os] = ARGV[2]
end
if options[:env] == true 
    options[:env] = ARGV[3]
end
if options[:size] == true 
    options[:size] = ARGV[4]
end
if options[:ami] == true 
    options[:ami] = ARGV[5]
else
    
end
if options[:intname] == true
    options[:intname] = ARGV[0]
else
    options[:intname] = ""
end

if options[:task] == 'info'
  if options[:intname].to_s != ''
    getInstanceInfo(options[:intname])
  else
    puts "Please pass the instance name to get details"
  end
end

hname=""
asubnet = Hash.new
asubnet = {"web1" => "subnet-1a0a2c6d", "web2" => "subnet-ca7a0293", "db1" => "subnet-180a2c6f", "db2" => "subnet-c87a0291", "stgweb1" => "subnet-e3d08294", "stgweb2" => "subnet-d0532489", "stgdb1" => "subnet-e2d08295", "stgdb2" => "subnet-d1532488"}
vacdet = {"prod" => "10.133.105.137", "mptdev" => "10.133.121.172" , "ehdev" => "10.133.121.110" , "wtedev" => "10.133.121.146", "demo" => "172.31.65.7"}
amidet = {"lweb" => "ami-e1a837f6", "cf" => "ami-4c57cf5b", "varnish" => "ami-2e198239", "wweb" => "ami-af7954b8"}
akeys = {
  "MPT" => "MPT-LiveLive",
  "EH"  => "liveliveaws",
  "WP"  => "AWS_Wordpress",
  "WTE" => "MPT-LiveLive",
  "DB"  => "MySQL_AWS"
}

sgroup = ["sg-61d30c06", "sg-b94521c0", "sg-069db863"]
sservers = {"mptstgweb" => "usnjstglweb10.waterfrontmedia.net", "mptprodweb" => "usnjlweb52.waterfrontmedia.net", "mptstgcf" => "usnjstglcf2016.waterfrontmedia.net", "mptprodcf" => "usnjlweb66.waterfrontmedia.net" }
aminame=""
if ( options[:ami] != true )
  if (options[:os].upcase == "LINUX" and options[:role].upcase == "WEB" )
    aminame = amidet["lweb"]
  elsif (options[:os].upcase == "LINUX" and options[:role].upcase == "CF" )
    aminame = amidet["cf"]
  elsif (options[:os].upcase == "LINUX" and options[:role].upcase == "VARNISH" )
    aminame = amidet["varnish"]
  elsif (options[:os].upcase == "WINDOWS" and options[:role].upcase == "WEB" )
    aminame = amidet["wweb"]
  elsif (options[:os].upcase == "WINDOWS" )
    aminame = amidet["wweb"]
  end
else
  aminame = options[:ami] 
end

sgroup = ["sg-61d30c06", "sg-b94521c0", "sg-069db863"]
sservers = {"mptstgweb" => "usnjstglweb10.waterfrontmedia.net", "mptprodweb" => "usnjlweb52.waterfrontmedia.net", "mptstgcf" => "usnjstglcf2016.waterfrontmedia.net", "mptprodcf" => "usnjlweb66.waterfrontmedia.net" }

#if ((options[:project].upcase != 'MPT') || (options[:project].upcase != 'WTE') || (options[:project].upcase != 'EH') || (options[:project].upcase != 'WP'))
#  puts "Didn't pass correct project #{options[:project].upcase}, please use [MPT/WTE/EH/WP]"
#  exit 0
#end
puts "AMI Image :  #{aminame}"

if options[:task] == 'create'
  if (options[:project].empty? == false ) && (options[:role].empty? == false) && (options[:os] != "os") && (options[:env] != "env")
    hname,cc = eh.getHostName(options[:project],options[:role],options[:os],options[:env])
    fhname="#{hname}"+".waterfrontmedia.net"
    subnet = eh.getSubnetDetails(cc,options[:role],options[:env],asubnet)
    proj = options[:project]
    pkey = akeys[proj.upcase]
    stat,str=eh.checkAMI(options[:size],aminame)
    if stat == 1
      puts "Didn't find AMI images which you passed #{aminame}"
      exit
    end
    filename=eh.generateUserData(fhname,options[:project],options[:role],options[:os],sshkey)
    cquery=eh.generateAWSQuery(pkey,subnet,sgroup,options[:size],aminame,filename,options[:os])
    intID=eh.createInstance(cquery)
    #fhname="awseswehweb01.waterfrontmedia.net"
    sleep 5
    if intID.include? "ERR"
      puts "Instances is not create and check AWS Web Console"    
      exit
    else
      puts "Instance is created with ID #{intID}"
      tquery=eh.generateAWSTags(hname,intID,options[:project],options[:role],options[:os],options[:env])
    end      
    stat,intIP = eh.getInstanceIP(intID)
    puts "Instance Details are : #{intID} --- #{fhname} --- #{intIP}"

    print "Instance is creating now  : "
    stat = eh.checkServerStatus(intIP,options[:os])
    puts ""
    puts "Instance Build is completed"
    print "Executing Post Installion Scripts : "

    if (options[:os].upcase == "WINDOWS")
      #puts "Rebooting the server after hostname changes :"
      #eh.stopInstance(intID)
      sleep 10
      #eh.startInstance(intID)
      eh.installWindowsModules(intIP,fhname)
    else
      eh.checkPostInstall(intIP,options[:os])
    end
 
    spath = `pwd | tr '\r\n' '/'`
    subv=""
    if (( options[:role] == 'web' || options[:role] == "cf" || options[:role] == 'wordpress' || options[:role] == 'wp') && (options[:os].upcase != "WINDOWS"))
      if (options[:role] != "cf" )
        eh.syncContent(hname,options[:project],options[:role],options[:os],options[:env],spath,intIP,subv)
      end
      stat1 = eh.generateBackend(intIP,hname,options[:project],options[:role],options[:os],options[:env])
      puts "#{stat1}"
    elsif ( options[:role] == 'varnish' )
      vacIP = "172.31.67.123"
      eh.varnishUpdates(intIP,options[:project],options[:role],options[:os],options[:env],vacIP)
    elsif (options[:os].upcase == "WINDOWS")
      stat = eh.syncContent(hname,options[:project],options[:role],options[:os],options[:env],spath,intIP,subv)
      if ( stat == "ERR" )
        puts "Error in syncing the Data to New servers"
      end
    end
current = DateTime.now
cdate = "#{current.month}-#{current.day}-#{current.year}-#{current.hour}:#{current.min}"
cdate.chomp
puts ""
puts "---- Ending #{cdate} --------"
  else
    puts "You need to pass Project/Role/OS/Env for new instance creation"
  end
end

