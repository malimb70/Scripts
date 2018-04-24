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


def getAllInstance(pstr,account,book)
	sheet1 = book.create_worksheet :name => "#{account}"
	sheet1.row(0).push  "Vol ID","Instance ID","Instance Name","Volume Size","Volume State","Tags"
	cmd = "aws ec2 #{pstr} describe-volumes --region us-east-1"
	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	if obj['Volumes'].any?
		array = obj['Volumes']
		cc=1
		array.each {|hash|
			intname=""
			volid=hash['VolumeId']
			volsize=hash['Size']
			volst=hash['State']
			if hash['Attachments'].any?
				intid=hash['Attachments'][0]['InstanceId']
				cmd1 = "aws ec2 describe-instances #{pstr} --region us-east-1 --instance-ids #{intid}"
				stdin, stdout, stderr, wait_thr = Open3.popen3("#{cmd1}")
    			str = stdout.read
    			if str.include? "Error 500"
					puts "Not able to get requested details "
    			else
					obj = JSON.parse(str)
    			end
    			if obj['Reservations'].any?
					array = obj['Reservations']
					array.each {|hash|
						if hash['Instances'][0].has_key?("Tags")
							arr1 = hash['Instances'][0]['Tags']
							arr1.each {|tags|
								if tags['Key'] == 'Name'
									intname=tags['Value']
								end
							}
						end
					}					
				end
			end
			voltag=""
			if hash.key?("Tags")
				if hash['Tags'].any?
					tags = hash['Tags']
					tags.each {|taglist|
						tname = taglist["Key"]
						tstr = taglist["Value"]
						voltag=voltag+"#{tname}:#{tstr},"
					}
				end	
			end
			sheet1.row(cc).push  "#{volid}","#{intid}","#{intname}","#{volsize}","#{volst}","#{voltag}"
			cc = cc+1
		}				
	else
		puts "Didn't found any instanace currently on this account "
		exit
	end
end

book = Spreadsheet::Workbook.new
puts "Starting ......"
getAllInstance("","ops",book)
puts "Ops Account Completed"
getAllInstance("--profile mpt","mpt",book)
puts "MPT Account Completed"
getAllInstance("--profile wte","wte",book)
puts "WTE Account Completed"
book.write '/tmp/aws_account_volumes.xls'
