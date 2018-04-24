#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby

require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'
require "./ehAWSAutomationClass"

options = {
  :task => 'task',
  :envir => 'envir',
  :project => 'project',
  :optinfo => false
}

dis=""
parser = OptionParser.new do |opts|
  opts.banner = "Usage: awsEHClitool.rb -t task -i instance_id -z zone [options] "

  opts.on('-t', '--task=MANDATORY', "Need to pass info/deploy/status/logs/list") do |p|
        options[:task] = p
  end

  opts.on('-e', '--env', "Pass Environment [stage/prod]") do |p|
    options[:env] = p
  end

  opts.on('-p', '--project', "Pass Project [MPT/EH/WTE/IMG/") do |p|
    options[:os] = p
  end

  opts.on('-g', '--optinfo', "Options for showing cluster storage and hosts details") do |o|
        options[:optinfo] = o
    end
        
    opts.on_tail("-h", "--help", <<__USAGE__) do
Show this message

Examples:
  varnishDeploy.rb --task [info/deploy/status/logs/list] --env [dev/qa/stage/prod] --project [mpt/eh/wte/img] 
  varnishDeploy.rb -t [info/deploy/status/logs/list] -e [dev/qa/stage/prod] -p [mpt/eh/wte/img] 
  varnishDeploy.rb -task deploy -project mpt -env prod 
  varnishDeploy.rb -t deploy -p mpt -e prod 
__USAGE__
    puts opts
    exit
    end     
end

parser.parse!

eh = EHAWSAutomationClass.new

current = DateTime.now
cdate = "#{current.month}-#{current.day}-#{current.year}-#{current.hour}:#{current.min}"
cdate.chomp
puts " ---- Starting #{cdate} --------"
if options[:task] == true 
    options[:task] = ARGV[0]
end
if options[:project] == true 
    options[:project] = ARGV[1]
end
if options[:envir] == true 
    options[:envir] = ARGV[2]
end

puts "#{options[:task]} --- #{options[:project]} ------------- #{options[:envir]}"