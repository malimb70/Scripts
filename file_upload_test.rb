#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby


sIP = "172.31.70.197"
dIP = "172.31.68.65"
spath = "/mnt/source"
dpath = "/mnt/dest"

user="Administrator"
spassword="4H3@lthyL1f3"

dpassword="Sr&jLxMHWq;"


scmd="mount -t cifs -o username=#{user},password='#{spassword}' //#{sIP}/D$/websites #{spath}"
dcmd="mount -t cifs -o username=#{user},password='#{dpassword}' //#{dIP}/D$ #{dpath}"

puts "#{scmd}"
puts "#{dcmd}"

smount=`mount | grep #{sIP} |wc -l |tr -d '\\n'`
dmount=`mount | grep #{dIP} |wc -l |tr -d '\\n'`
if smount == "1"
    puts "source mount"
else
    system (scmd)
end

if dmount == "1"
    puts "dest mount"
else
    system (dcmd)
end

if (smount == "0" && dmount == "0")
    puts "Source and Dist is not mounted"
else
    if Dir.exists?("/mnt/dest/websites")

    else
        `mkdir /mnt/dest/websites`
    end
    cmd="cp -r /mnt/source/* /mnt/dest/websites/"
    system (cmd)
end

