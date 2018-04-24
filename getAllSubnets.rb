#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby

require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'
require 'spreadsheet' 
require "./ehAWSAutomationClass"

def getAllSubnets(pstr,account,book)
	puts "Starting Account #{account}"
	obj=""
	sheet1 = book.create_worksheet :name => "#{account}"
	sheet1.row(0).push  "VPC IP","Subnet ID","CIDR Block","AZ Zone","Status","Name","Product","Environment"
	cmd = "aws ec2 describe-subnets #{pstr} --region us-east-1"
	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	cc=1
	if obj['Subnets'].any?
		array = obj['Subnets']
		array.each {|hash|
			subname=""
			subid=""
			subproj=""
			subenv=""
			vpcid=""
			cidrblock=""
			substate=""
			azone=""
			subid=hash['SubnetId']
			if hash.key?("Tags")
				arr1 = hash['Tags']
				arr1.each {|tags|
					if tags['Key'] == 'Name'
						subname=tags['Value']
					end
					if (tags['Key'] == 'Project' or tags['Key'] == 'project')
						subproj=tags['Value']
					end
					if (tags['Key'] == 'envir' or tags['Key'] == 'Envir')
						subenv=tags['Value']
					end
				}
			end
			cidrblock=hash['CidrBlock']
			vpcid=hash['VpcId']
			substate=hash['State']
			azone=hash['AvailabilityZone']
			sheet1.row(cc).push  "#{vpcid}","#{subid}","#{cidrblock}","#{azone}","#{substate}","#{subname}","#{subproj}","#{subenv}"
			cc = cc+1
			intresult = "#{vpcid},#{cidrblock},#{azone},#{subname},#{subproj},#{subenv}"
			puts "#{intresult}"
		}				
	else
		puts "Didn't found any instanace currently on this account "
	end
end

book = Spreadsheet::Workbook.new
getAllSubnets("","OPS",book)
getAllSubnets(" --profile mpt","MPT",book)
getAllSubnets(" --profile wte","WTE",book)
getAllSubnets(" --profile cddi","CDDI",book)
getAllSubnets(" --profile edhdev","EH",book)
getAllSubnets(" --profile tea","TEA",book)
getAllSubnets(" --profile corp","EHCORP",book)
book.write '/tmp/aws_account_subnets.xls'