#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby

require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'
require 'resolv'
require "net/http"
require "uri"

class EHVarnishAutomationClass
	@@username="vac"
	@@password="vac"
	def initialize

	end

	def createGroup(name,desc,vacIP)
		str = getGroupID(name,vacIP)
		uname=@@username
		passw=@@password
		if str == "ERR"
			cmd = "curl -u #{uname}:#{passw} -X POST http://#{vacIP}:8181/api/v1/group/ -d \"{\"name\": \"#{name}\"}\" -H \"Content-Type: application/json\""
			stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        	str1 = stdout1.read	
        	obj = JSON.parse(str1)
        	gid = "#{obj['_id']['$oid']}"
        	return gid
		else
			return "ERR"
		end
	end

	def createVCLs(name,desc,vacIP)
		str = getVCLs(name,vacIP)
		uname=@@username
		passw=@@password
		if str == "ERR"
			cmd = "curl -u #{uname}:#{passw} -X POST http://#{vacIP}:8181/api/v1/vcl/ -d \"{\"name\": \"#{name}\"}\" -H \"Content-Type: application/json\""
			stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        	str1 = stdout1.read	
        	obj = JSON.parse(str1)
        	gid = "#{obj['_id']['$oid']}"
        	return gid
		else
			return "ERR"
		end
	end

	def displayGroup(vacIP)
		result = Hash.new
		uri = URI.parse("http://#{vacIP}:8181/api/v1/group")

		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(@@username, @@password)

		response = http.request(request)
		if response.body.include? "list"
			obj = JSON.parse(response.body)
			pretty_str = JSON.pretty_unparse(obj)

			obj["list"].each {|data1|
				gname = data1["name"]
				gid = data1["_id"]["$oid"]
				result[gname] = gid 
			}
		else
			return "ERR"
		end
		return result
	end

	def getGroupID(groupname,vacIP)
		uri = URI.parse("http://#{vacIP}:8181/api/v1/group")
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(@@username, @@password)
		response = http.request(request)
		if response.body.include? "list"
			obj = JSON.parse(response.body)
			pretty_str = JSON.pretty_unparse(obj)
			gid=""
			obj["list"].each {|data1|
				gname = data1["name"]
				g1 = groupname.upcase
				g2 = gname.upcase
				if g2["#{g1}"]
					gid = data1["_id"]["$oid"]
					break	
				else
					gid = "ERR"
				end
			}
			return gid
		else
			return "ERR"
		end
	end

	def getCacheServerID(serverIP,vacIP)

		uri = URI.parse("http://#{vacIP}:8181/api/v1/cache")

		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(@@username, @@password)
		response = http.request(request)

		if response.body.include? "list"
			obj = JSON.parse(response.body)
			pretty_str = JSON.pretty_unparse(obj)
			str=""
			obj["list"].each {|data1|
				gname = data1["groupName"]
				cid = data1["_id"]["$oid"]
				ahost = data1["agentHost"]
				if ahost["#{serverIP}"]
					str = "#{gname}:#{cid}:#{ahost}"
					break
				else
					str = "ERR"
				end
			}
			return str
		else
			return "ERR"
		end
	end

	def displayCache(vacIP)
		result = Hash.new
		uri = URI.parse("http://#{vacIP}:8181/api/v1/cache")

		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(@@username, @@password)
		response = http.request(request)

		if response.body.include? "list"
			obj = JSON.parse(response.body)
			obj["list"].each {|data1|
				gname = data1["groupName"]
				cid = data1["_id"]["$oid"]
				ahost = data1["agentHost"]
				val1 = "#{gname}:#{cid}"
				result[ahost] = val1	
			}
		else
			return "ERR"
		end
		return result
	end

	def getVCLs(vname,vacIP)

		uri = URI.parse("http://#{vacIP}:8181/api/v1/vcl")
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(@@username, @@password)
		response = http.request(request)

		if response.body.include? "list"
			obj = JSON.parse(response.body)
			str=""
			obj["list"].each {|data1|

				gname = data1["groupName"]
				cid = data1["_id"]["$oid"]
				ahost = data1["name"]

				if ahost["#{vname}"]
					str = "#{gname}:#{cid}:#{ahost}"
					break
				else
					str = "ERR"
				end
			}
			if str.length < 3
				return "ERR"
			else
				return str
			end
		else
			return "ERR"
		end
	end

	def displayVCLs(vacIP)
		result = Hash.new
		uri = URI.parse("http://#{vacIP}:8181/api/v1/vcl")

		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(@@username, @@password)
		response = http.request(request)

		if response.body.include? "list"
			obj = JSON.parse(response.body)

			obj["list"].each {|data1|
				gname = data1["groupName"]
				vclid = data1["_id"]["$oid"]
				vclname = data1["name"]
				val1="#{gname}:#{vclid}"
				result[vclname] = val1
			}
		else
			return "ERR"
		end
		return result
	end

	def addServertoGroup(groupid,serverid,vacIP)
		ustr="http://#{vacIP}:8181/api/v1/group/#{groupid}/include/#{serverid}"
		uri = URI.parse("#{ustr}")
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Put.new(uri.request_uri)
		request.basic_auth(@@username, @@password)
		response = http.request(request)
		status = response.body
		if status["OK"]
			return true
		else
			return false
		end
	end

	def deployVCLtoGroup(groupid,vclID,vacIP)
		ustr="http://#{vacIP}:8181/api/v1/group/#{groupid}/vcl/#{vclID}/deploy"
		uri = URI.parse("#{ustr}")
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Put.new(uri.request_uri)
		request.basic_auth(@@username, @@password)
		response = http.request(request)
		status = response.body
		puts "#{status}"
		if status["deployment successful"]
			return true
		else
			return false
		end
	end

	def deployVCLs(name,vclID,filename,vacIP)
		str = getGroupID(name,vacIP)
		uname=@@username
		passw=@@password
		if str == "ERR"
			fpath="@#{filename}"
			cmd = "curl -u #{uname}:#{passw} -X POST http://#{vacIP}:8181/api/v1/vcl/#{vclID}/push -H \"Content-Type: text/plain\"  --data-binary \"#{fpath}\""
			stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        	str1 = stdout1.read	
        	obj = JSON.parse(str1)
        	gid = "#{obj['_id']['$oid']}"
        	return gid
		else
			puts "VCL Name is not Exists : #{name}"
			return "ERR"
		end
	end
end

#ehvarnish = EHVarnishAutomationClass.new
#vacIP="10.133.121.146"
#result = Hash.new
#puts "------------------ Cache Groups --------------"
#result = ehvarnish.displayGroup(vacIP)
#result.each { |key,value| 
#	puts "#{key}=>#{value}" 
#}
#puts "------------------ Cache Servers --------------"
#result=ehvarnish.displayCache(vacIP)
#result.each { |key,value| 
#	puts "#{key}=>#{value}" 
#}
#ehvarnish.createGroup('Test1','Testing 1',vacIP)
#groupid = ehvarnish.getGroupID('Test',vacIP)
#cachestr = ehvarnish.getCacheServerID('10.133.122.87',vacIP)

#gname,cacheid,serverIP = cachestr.split(":")
#puts "#{groupid} -- #{cacheid}"
#if gname["all"]
#	if ehvarnish.addServertoGroup(groupid,cacheid,vacIP)
#		puts "Server is successfull deployed in to #{gname} group"
#	else
#		puts "Failed to deploy #{serverIP} to #{gname}"
#		exit 0
#	end
#else
#	puts "Server is already in #{gname} Cache Group"
#end

#vname = "test_vcl"
#vclid=ehvarnish.createVCLs(vname,'Testing VCL',vacIP)
#puts "------------------ VCLs  --------------"
#result=ehvarnish.displayVCLs(vacIP)
#result.each { |key,value| 
#	puts "#{key}=>#{value}" 
#}
#gname,vclID,vclname=ehvarnish.getVCLs(vname,vacIP).split(":")

#filename="/home/WATERFRONTMEDIA/sraju/eh/test_vcl.vcl"
#depID=ehvarnish.deployVCLs(vname,vclID,filename,vacIP)

#if ehvarnish.deployVCLtoGroup(groupid,vclID,vacIP)
#	puts "Deployed successfull"
#else
#	puts "Failed to deploy to group"
#end