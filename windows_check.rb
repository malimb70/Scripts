#!/usr/local/bin/ruby
#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby

require 'winrm'
require 'winrm-fs'
require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'

serverIP="10.133.121.84"
sname="awseswehweb01.waterfrontmedia.net"
opts = { 
  endpoint: "http://#{serverIP}:5985/wsman",
  user: 'administrator',
  password: '4H3@lthyL1f3'
}

chostname=""
conn = WinRM::Connection.new(opts)

conn.shell(:powershell) do |shell|
  output = shell.run('hostname') do |stdout, stderr|
    chostname=stdout
	STDOUT.print stdout
    STDERR.print stderr
  end
end

file_manager = WinRM::FS::FileManager.new(conn)
file_manager.upload(['/home/WATERFRONTMEDIA/sraju/eh/user-data-windows-s1.ps1','/home/WATERFRONTMEDIA/sraju/eh/user-data-windows-s2.ps1'], 'c:/scripts/')

#conn.shell(:powershell) do |shell|
#  output = shell.run('C:\scripts\user-data-windows-s1.ps1') do |stdout, stderr|
#    STDOUT.print stdout
#    STDERR.print stderr
#  end
#end

puts "Changed the hostname and rebooting the server .."
sleep 10
status = "down"
while status != "up"
    print "."
    sleep 3
    cmd = "sleep 1 |telnet 10.133.121.84 5985 |grep 'Escape' |wc -l |tr -d '\n'"
    stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    val1 = stdout1.read
    val1.chomp
    if val1 == "1"
      status = "up"
    else
      status = "down"
    end
end

#conn.shell(:powershell) do |shell|
#  output = shell.run('C:\scripts\user-data-windows-s2.ps1') do |stdout, stderr|
#    STDOUT.print stdout
#    STDERR.print stderr
#  end
#end

puts "Installed IIS and other Modules and restarting .."
sleep 10
status = "down"
while status != "up"
    print "."
    sleep 3
    cmd = "sleep 1 |telnet 10.133.121.84 5985 |grep 'Escape' |wc -l |tr -d '\n'"
    stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    val1 = stdout1.read
    val1.chomp
    if val1 == "1"
      status = "up"
    else
      status = "down"
    end
end

conn.shell(:powershell) do |shell|
  output = shell.run('puppet agent -t') do |stdout, stderr|
    STDOUT.print stdout
    STDERR.print stderr
  end
end

conn.shell(:powershell) do |shell|
  output = shell.run('puppet agent -t') do |stdout, stderr|
    STDOUT.print stdout
    STDERR.print stderr
  end
end

conn.shell(:powershell) do |shell|
  output = shell.run('puppet agent -t') do |stdout, stderr|
    STDOUT.print stdout
    STDERR.print stderr
  end
end