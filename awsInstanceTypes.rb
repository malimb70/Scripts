#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby

require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'
require 'spreadsheet' 
require "./ehAWSAutomationClass"

#Spreadsheet.client_encoding = 'UTF-8'

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

if options[:account] == true 
    options[:account] = ARGV[0]
end

if options[:zone] == true 
    options[:zone] = ARGV[1]
end

astr = options[:account].upcase

pstr = ""
if options[:account].upcase == "OPS"
	pstr = ""
else 
	pstr = " --profile #{options[:account].downcase}"
end

def getAllInstance(pstr,account)
	instDet = Hash.new 

	#ec2details = File.new("/tmp/awsdata/#{account}_ec2instancedetails.csv", "w+")
	cmd = "aws ec2 describe-instances #{pstr} --region us-east-1"
	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	if obj['Reservations'].any?
		array = obj['Reservations']
		array.each {|hash|
			intst=hash['Instances'][0]['State']['Name']
			intintype=hash['Instances'][0]['InstanceType']
			instDet["#{intintype}"] = instDet["#{intintype}"].to_i + 1
		}				
	else
		puts "Didn't found any instanace currently on this account "
		exit
	end
	#ec2details.close
	return instDet
end

book = Spreadsheet::Workbook.new

ec2intdet = getAllInstance("--profile mpt","mpt")
ec2intdet.sort
sheet1 = book.create_worksheet :name => 'MPT'
sheet1.row(0).push  "Instance Type","No. Instance Running"
cc=1
ec2intdet.each {|key, value|
	insttype = key
	sheet1.row(cc).push  "#{key}","#{value}"
	cc = cc+1
}

ec2intdet = getAllInstance("--profile wte","wte")
ec2intdet.sort
sheet1 = book.create_worksheet :name => 'WTE'
sheet1.row(0).push  "Instance Type","No. Instance Running"
cc=1
ec2intdet.each {|key, value|
	insttype = key
	sheet1.row(cc).push  "#{key}","#{value}"
	cc = cc+1n
}

ec2intdet = getAllInstance("","ops")
ec2intdet.sort
sheet1 = book.create_worksheet :name => 'OPS'
sheet1.row(0).push  "Instance Type","No. Instance Running"
cc=1
ec2intdet.each {|key, value|
	insttype = key
	sheet1.row(cc).push  "#{key}","#{value}"
	cc = cc+1
}

ec2intdet = getAllInstance("--profile eh","eh")
ec2intdet.sort
sheet1 = book.create_worksheet :name => 'EH'
sheet1.row(0).push  "Instance Type","No. Instance Running"
cc=1
ec2intdet.each {|key, value|
	insttype = key
	sheet1.row(cc).push  "#{key}","#{value}"
	cc = cc+1
}

book.write '/tmp/aws_account_ec2_instances.xls'
