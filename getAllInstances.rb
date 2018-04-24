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
	sheet1.row(0).push  "Instance ID","Instance Name","Instance Type","Status","Private IP","Public IP","Product","Environment"
	cmd = "aws ec2 describe-instances #{pstr} --region us-east-1"
	stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    str = stdout1.read
    if str.include? "Error 500"
		puts "Not able to get requested details "
    else
		obj = JSON.parse(str)
    end
	cc=1
	if obj['Reservations'].any?
		array = obj['Reservations']
		array.each {|hash|
			intname=""
			intnameproj=""
			intnameevr=""
			intnamerole=""
			intid=hash['Instances'][0]['InstanceId']
			if hash['Instances'][0].key?("Tags")
				arr1 = hash['Instances'][0]['Tags']
				arr1.each {|tags|
					if tags['Key'] == 'Name'
						intname=tags['Value']
					end
					if (tags['Key'] == 'envir' or tags['Key'] == 'Envir')
						intnameevr=tags['Value']
					end
					if (tags['Key'] == 'product' or tags['Key'] == 'product')
						intnamerole=tags['Value']
					end
				}
			end
			intst=hash['Instances'][0]['State']['Name']
			intprip=hash['Instances'][0]['PrivateIpAddress']
			intpuip=hash['Instances'][0]['PublicIpAddress']
			intkey=hash['Instances'][0]['KeyName']
			intintype=hash['Instances'][0]['InstanceType']
			
			sheet1.row(cc).push  "#{intid}","#{intname}","#{intintype}","#{intst}","#{intprip}","#{intpuip}","#{intnameevr}","#{intnamerole}"
			cc = cc+1
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
book.write '/tmp/aws_account_instances.xls'