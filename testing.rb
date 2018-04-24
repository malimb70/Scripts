#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby
#
require 'resolv'
require './dns_check'
#Resolv::DNS.new.getaddress("awsestglmpt01.waterfrontmedia.net") { |addr| puts addr }

if (DnsCheck.new("awsestglmpt02.waterfrontmedia.net").a? )
  puts "Found the record"
else
  puts "Not Found"
end
puts "Testing"
