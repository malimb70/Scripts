#!/usr/local/rvm/rubies/ruby-2.4.1/bin/ruby

require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'
require 'spreadsheet' 
#require "./ehAWSAutomationClass"

options = {
  :account => 'account',
  :zone => 'zone',
  :optinfo => false
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: awsEHReports.rb -a account -z zone [options] "

  opts.on('-a', '--account=MANDATORY', "Need to pass mpt/wte/ops/eh/cor/cdn") do |p|
		options[:account] = p
  end

  opts.on('-z', '--zone', "Pass Zone of AWS") do |z|
		options[:zone] = z
  end

	opts.on_tail("-h", "--help", <<__USAGE__) do
Show this message

Examples:
	awsEHReports.rb -a mpt 
	awsEHReports.rb -a ops 

__USAGE__
    puts opts
    exit
    end  	
end

parser.parse!

ec2intdet = Hash.new 

trdsinst = 0
totlb = 0
toteip = 0
totusers = 0
totsecgrp = 0
totkeys = 0
totvol = 0

if options[:account] == true 
    options[:account] = ARGV[0]
end

if options[:zone] == true 
    options[:zone] = ARGV[1]
end

astr = options[:account].upcase

puts "#{options[:account].upcase}  ---- #{astr}"
#if (( astr != "OPS" ) or (astr != "MPT" )) #|| astr != "WTE" || astr != "EH" || astr != "CORP" || astr != "CDN")
#	puts "You passed wrong profile to script, need to pass any one of the profile [ops/mpt/wte/eh/corp/cdn]"
#	exit
#end

pstr = ""
if options[:account].upcase == "OPS"
	pstr = ""
else 
	pstr = " --profile #{options[:account].downcase}"
end

def getAllInstance(pstr,account)
	tec2instrun = 0
	tec2instst = 0
	tec2instost = 0
	obj=""
	ec2details = File.new("/tmp/awsdata/#{account}_ec2instancedetails.csv", "w+")
	cmd = "aws ec2 describe-instances #{pstr} --region us-east-1"
	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	if obj['Reservations'].any?
		puts "Instance ID,Instance Name,Status,Private IP,Public IP,Server Key,Instance Type,Environment,Role,OS Type"
		array = obj['Reservations']
		array.each {|hash|
			intname=""
			intnameproj=""
			intnameevr=""
			intnamerole=""
			ostype=""
			intid=hash['Instances'][0]['InstanceId']
			if hash['Instances'][0].has_key?("Tags")
				arr1 = hash['Instances'][0]['Tags']
				arr1.each {|tags|
					if tags['Key'] == 'Name'
						intname=tags['Value']
					end
					if (tags['Key'] == 'Environment' or tags['Key'] == 'environment')
						intnameevr=tags['Value']
					end
					if (tags['Key'] == 'Role' or tags['Key'] == 'role')
						intnamerole=tags['Value']
					end
				}
			end
			intst=hash['Instances'][0]['State']['Name']
			intprip=hash['Instances'][0]['PrivateIpAddress']
			intpuip=hash['Instances'][0]['PublicIpAddress']
			intkey=hash['Instances'][0]['KeyName']
			intintype=hash['Instances'][0]['InstanceType']
			if hash['Instances'][0].has_key?("Platform")
				intinplat=hash['Instances'][0]['Platform']
				if intinplat == "windows"
				   ostype="Windows"
				else
				   ostype="Others"
				end
			else
				ostype = "Linux/Ubuntu"
			end
			if intst == "running"
				tec2instrun = tec2instrun.to_i + 1
			elsif intst == "stopped"
				tec2instst = tec2instst.to_i + 1
			else
				tec2instost = tec2instst.to_i + 1
			end
			
			intresult = "#{intid},#{intname},#{intst},#{intprip},#{intpuip},#{intkey},#{intintype},#{intnameevr},#{intnamerole},#{ostype}"
			ec2details.puts("#{intresult}")
		}				
	else
		puts "Didn't found any instanace currently on this account "
		exit
	end
	ec2details.close
	return "#{account},#{tec2instrun},#{tec2instst},#{tec2instost}"
end

def getRDSInstances(pstr,account)
	trdsinstrun = 0
	obj=""
	ec2details = File.new("/tmp/awsdata/#{account}_rdsinstancedetails.csv", "w+")
	cmd = "aws rds #{pstr} --region us-east-1 describe-db-instances "
	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	if obj['DBInstances'].any?
		ec2details.puts("RDS Name,RDS DNS Name,Status,RDS Type,RDS Version,RDS Port,MultiAZ,RDS Size,Encryption")
		
		array = obj['DBInstances']
		array.each {|hash|
			intname=""
			intst=""
			intdnsname=""
			inttype=""
			intmulti=""
			intport=""
			intengver=""
			intsize=""
			intname=hash['DBInstanceIdentifier']
			intst=hash['DBInstanceStatus']
			intdnsname=hash['Endpoint']['Address']
			inttype=hash['Engine']
			intmulti=hash['MultiAZ']
			intport=hash['Endpoint']['Port']
			intengver=hash['EngineVersion']
			intsize=hash['DBInstanceClass']
			intencr=hash['StorageEncrypted']
			if intst == "available"
				trdsinstrun = trdsinstrun.to_i + 1
			end
			intresult = "#{intname},#{intdnsname},#{intst},#{inttype},#{intengver},#{intport},#{intmulti},#{intsize},#{intencr}"
			ec2details.puts("#{intresult}")
		}				
	else
		puts "Didn't found any instanace currently on this account "
		exit
	end
	ec2details.close
	return trdsinstrun
end

#ec2intcount = File.new("/tmp/awsdata/all_ec2instancecount.csv", "w+")
#str3 = getAllInstance("--profile wte","wte")
#ec2intcount.puts(str3)
#str1 = getAllInstance("","ops")
#ec2intcount.puts(str1)
#str2 = getAllInstance("--profile mpt","mpt")
#ec2intcount.puts(str2)
#ec2intcount.close

ec2intcount = File.new("/tmp/awsdata/all_rdsinstancecount.csv", "w+")
str3 = getRDSInstances("--profile wte","wte")
str1 = getRDSInstances("","ops")
str2 = getRDSInstances("--profile mpt","mpt")
str4 = getRDSInstances("--profile eh","eh")
str5 = getRDSInstances("--profile tea","tea")
puts "#{str1} ---- #{str2} ---- #{str3} ---- #{str4} ---- #{str5} "
ec2intcount.close