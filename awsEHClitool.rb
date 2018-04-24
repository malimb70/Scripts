#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby

require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'

options = {
    :task => 'task',
    :intname => 'intname',
	:zone => 'zone',
	:profile => 'profile',
    :optinfo => false
}

parser = OptionParser.new do |opts|
    opts.banner = "Usage: awsEHClitool.rb -t task -i instance_id -z zone [options] "

    opts.on('-t', '--task=MANDATORY', "Need to pass info/status/stop/start/list") do |p|
		options[:task] = p
    end

    opts.on('-i', '--intname', "Pass Tasks Instance Name") do |p|
		options[:intname] = p
    end

    opts.on('-z', '--zone', "Pass Zone of AWS") do |z|
		options[:zone] = z
    end

    opts.on('-p', '--profile', "Profile ") do |p|
		options[:profile] = p
    end

    opts.on('-o', '--optinfo', "Options for showing cluster storage and hosts details") do |o|
		options[:optinfo] = o
	end
		
	opts.on_tail("-h", "--help", <<__USAGE__) do
Show this message

Examples:
  awsEHClitool.rb  -t info -i instance_name -z us-east-1
  awsEHClitool.rb  -t start -i instance_id -z us-east-1 
  awsEHClitool.rb  -t stop -i instance_id -z us-east-1 [options]
  awsEHClitool.rb  -t status -i instance_id -z us-east-1 [options]
  
__USAGE__
    puts opts
    exit
    end  	
end

def getInstanceStatus(intname)
	cmd = "aws ec2 describe-instances --filters Name=tag-value,Values=#{intname} --region us-east-1"
 	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	if obj['Reservations'].any?
		intst=obj['Reservations'][0]['Instances'][0]['State']['Name']
		return intst
	else
		puts "Requested instance #{intname} not found in this AWS "
		exit
	end
end

def getInstanceID(intname)
	cmd = "aws ec2 describe-instances --filters Name=tag-value,Values=#{intname} --region us-east-1"
 	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	if obj['Reservations'].any?
		intid=obj['Reservations'][0]['Instances'][0]['InstanceId']
		return intid
	else
		puts "Requested instance #{intname} not found in this AWS "
		exit
	end
end

def getInstanceInfo(intname,pstr)
	cmd = "aws ec2 describe-instances --filters Name=tag-value,Values=#{intname} --region us-east-1 #{pstr}"
	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	if obj['Reservations'].any?
		intid=obj['Reservations'][0]['Instances'][0]['InstanceId']
		intst=obj['Reservations'][0]['Instances'][0]['State']['Name']
		intprip=obj['Reservations'][0]['Instances'][0]['PrivateIpAddress']
		intpuip=obj['Reservations'][0]['Instances'][0]['PublicIpAddress']
		intkey=obj['Reservations'][0]['Instances'][0]['KeyName']
		intintype=obj['Reservations'][0]['Instances'][0]['InstanceType']
		puts "Instance ID | Instance Name | Status | Private IP | Public IP | Server Key | Instance Type "
		puts "#{intid} | #{intname} | #{intst} | #{intprip} | #{intpuip} | #{intkey} | #{intintype} "
	else
		puts "Requested instance #{intname} not found in this AWS "
		exit
	end
end

def getAllInstance(pstr)
	cmd = "aws ec2 describe-instances --region us-east-1 #{pstr}"
	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	if obj['Reservations'].any?
		puts "Instance ID | Instance Name | Status | Private IP | Public IP | Server Key | Instance Type | Project | Environment | Role |"
		array = obj['Reservations']
		array.each {|hash|
			intname=""
			intnameproj=""
			intnameevr=""
			intnamerole=""
			intid=hash['Instances'][0]['InstanceId']
			arr1 = hash['Instances'][0]['Tags']
			arr1.each {|tags|
				if tags['Key'] == 'Name'
					intname=tags['Value']
				end
				if tags['Key'] == 'Project'
					intnameproj=tags['Value']
				end
				if tags['Key'] == 'Environment'
					intnameevr=tags['Value']
				end
				if tags['Key'] == 'Role'
					intnamerole=tags['Value']
				end
			}
			intst=hash['Instances'][0]['State']['Name']
			intprip=hash['Instances'][0]['PrivateIpAddress']
			intpuip=hash['Instances'][0]['PublicIpAddress']
			intkey=hash['Instances'][0]['KeyName']
			intintype=hash['Instances'][0]['InstanceType']
			puts "#{intid} | #{intname} | #{intst} | #{intprip} | #{intpuip} | #{intkey} | #{intintype} | #{intnameproj} | #{intnameevr} | #{intnamerole}  | "
		}				
	else
		puts "Didn't found any instanace currently on this account "
		exit
	end
end

parser.parse!

# Get current date.
current = DateTime.now
cdate = "#{current.month}-#{current.day}-#{current.year}"
cdate.chomp

if options[:zone] == true 
    options[:zone] = ARGV[1]
end
if options[:profile] == true 
    options[:profile] = ARGV[0]
end
if options[:intname] == true
    options[:intname] = ARGV[1]
else
    options[:intname] = ""
end

pstr=""
if options[:profile] != "profile"
	pstr="--profile #{options[:profile]}"
else
	pstr=""
end

if options[:task] == 'info'
	if options[:intname].to_s != ''
		getInstanceInfo(options[:intname],pstr)
	else
		puts "Please pass the instance name to get details"
	end
end

if options[:task] == 'list'
	getAllInstance(pstr)
end

if options[:task] == 'start'
    if  options[:intname].to_s == ''
		puts "Please pass the instance name to get details"
		puts "awsEHClitool.rb  -t start -i instance_id #{pstr}"
    else
		intst=getInstanceStatus(options[:intname])
		if intst == 'running' 
			puts "Requested Instance #{options[:intname]} is already running state"
		else
			intid=getInstanceID(options[:intname])
			cmd = "aws ec2 start-instances --instance-ids #{intid} #{pstr}"
			stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
			str = stdout1.read
			if str.include? "Error 500"
				puts "Not able to get requested details "
			else
				obj = JSON.parse(str)
			end
			puts " Starting #{options[:intname]} now ...... "
			status = "stopped"
	        while status != "running" do
				print "."
				sleep 2
				status=getInstanceStatus(options[:intname])
			end
			print "\n #{options[:intname]} is started now \n"
		end
	end
end


if options[:task] == 'stop'
    if  options[:intname].to_s == ''
		puts "Please pass the instance name to get details"
		puts "awsEHClitool.rb  -t stop -i instance_id"
    else
		intst=getInstanceStatus(options[:intname])
		if intst == 'stopped' 
			puts "Requested Instance #{options[:intname]} is already stopped state"
		else
			intid=getInstanceID(options[:intname])
			cmd = "aws ec2 stop-instances --instance-ids #{intid} #{pstr}"
			stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
			str = stdout1.read
			if str.include? "Error 500"
				puts "Not able to get requested details "
			else
				obj = JSON.parse(str)
			end
			puts " Stopping #{options[:intname]} now ...... "
			status = "running"
	        while status != "stopped" do
				print "."
				sleep 2
				status=getInstanceStatus(options[:intname])
			end
			print "\n #{options[:intname]} is stopped now \n"
		end
	end
end
