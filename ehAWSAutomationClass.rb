#!/usr/local/rvm/rubies/ruby-2.1.8/bin/ruby

require 'rubygems'
require 'optparse'
require 'open3'
require 'json'
require 'date'
require 'resolv'
require 'winrm'
require 'winrm-fs'
require './dns_check'
require "./varnishAPIScript"

class EHAWSAutomationClass
	def initialize

	end

	def getHostName(project1,role1,os1,env1)
        cmd = "ldapsearch -x -h \"172.31.22.107\" -b \"dc=WATERFRONTMEDIA,dc=NET\" -D \"svc_puppet@WATERFRONTMEDIA.NET\" -w `cat /home/WATERFRONTMEDIA/sraju/.pass` -s sub \"(objectCategory=computer)\" cn |grep 'cn' |cut -d':' -f2 |sort > /tmp/comptuerlist.txt"
 		stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
    	str = stdout1.read
       	oval=""
    	hstr=""
    	if os1 == "linux"
    		oval="l"
    	else
    		oval="w"
    	end

        rol1=role1.downcase
        if (rol1 == "mysql" || rol1 == "mssql" )
            role = "db"
        elsif (rol1 == "varnish" )
            role = "vc"
        else
            role = rol1
        end

        if project1 == "db"
            proj = ""
        else
            proj = project1
        end
    	if env1 == "prod"
    		hstr = "awse#{oval}#{proj}#{role}"
    	else
            hstr = "awses#{oval}#{proj}#{role}"
    	end

        ehosts = Array.new
    	File.open("/tmp/comptuerlist.txt", "r") do |f|
  			f.each_line do |line|
  				val = line.downcase
  				val1 = val.strip
    	    	if  (val1 =~ /^#{hstr}/)
    	    		#puts "#{val1}"
                    ehosts.push(val1)    
    	    	end
    	    end
    	end 
        h1 = 0
        ehosts.sort
        ehosts.each { |hostn|
            h1 = hostn[-1,2]
        }
        h1 = "0"
        nhost = ""
        h1 = h1.to_i + 1
        if (h1 < 10)
            nhost = "#{hstr}0#{h1}"
        else
            nhost = "#{hstr}#{h1}"
        end
        stat = checkHostAvailable(nhost)   
        
        while stat != 2 do
            h1 = h1.to_i + 1
            if (h1 < 10)
                nhost = "#{hstr}0#{h1}"
            else
                nhost = "#{hstr}#{h1}"
            end
            stat = checkHostAvailable(nhost)  
        end
        return nhost,h1
	end

    def checkServerStatus(intIP,osinfo)
        p1 = ""
        if ( osinfo.downcase == "linux" )
            p1 = "22"
        elsif ( osinfo.downcase == "windows" )
            p1 = "5985"
        end
        if ( p1 != "" )
            status = "down"
            while status != "up"
                print "."
                sleep 3
                cmd = "nc -zv -w 3 #{intIP} #{p1} | grep 'Connection' |wc -l | tr -d '\\n'"
                stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
                val1 = stdout1.read
                val1.chomp
                if val1 == "1"
                    status = "up"
                else
                    status = "down"
                end
            end
        else
            return "ERR"
        end
        return 0
    end

    def checkPostInstall(intIP,osinfo)
        if intIP.length > 3
            if ( osinfo.upcase == "LINUX" )
                status = "stopped"
                while status != "running" do
                    print "*"
                    sleep 3
                    cmd="ssh -o StrictHostKeyChecking=no -i /home/WATERFRONTMEDIA/sraju/.ssh/id_rsa root@#{intIP} \"if [ -f /tmp/completed ]; then cat /tmp/completed | tr '\r\n' ' '; else echo 0; fi \""
                    stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
                    val1 = stdout1.read
                    val1.chomp
                    if val1 == "100 "
                        status = "running"
                    else
                        status = "stopped"
                    end
                end
            elsif ( osinfo.upcase == "WINDOWS" )
                sleep 10
                checkServerStatus(intIP,osinfo)
                sleep 10
                installWindowsModules(intIP)
            end 
        end
    end

    def windowsLogin(serverIP)
        opts = { 
            endpoint: "http://#{serverIP}:5985/wsman",
            user: 'administrator',
            password: 'Sr&jLxMHWq;'
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
    end

    def checkHostAvailable(nhost)
        fhost = "#{nhost}.waterfrontmedia.net"
        if ( DnsCheck.new("#{fhost}").a? )
            return 1
        else
            return 2
        end
    end

    def generateUserData(hname,project,role1,os,sshkey)
        rol1=role1.downcase
        os1=os.downcase
        ufile=""
        if (rol1 == "mysql" || rol1 == "mssql" )
            role = "db"
        else
            role = rol1
        end
        if ( os1.upcase == 'LINUX' && rol1 == "mysql" )
            ufile = "/home/WATERFRONTMEDIA/sraju/eh/user-data-mysql.sh"
        elsif ( os1.upcase == 'LINUX' && project.upcase == "MPT" )
            if role1.upcase == "COLDFUSION"
                rol1="cf"
            else
                rol1 = role1
            end
            ufile = "/home/WATERFRONTMEDIA/sraju/eh/user-data-linux-#{project}#{rol1}.sh"
        elsif ( os1.upcase == "WINDOWS")
            ufile = "/home/WATERFRONTMEDIA/sraju/eh/user-data-windows-s1.ps1"
        else
            ufile = "/home/WATERFRONTMEDIA/sraju/eh/user-data-linux.sh"
        end
        outfile = ""
        if ( os1.upcase == "WINDOWS")
            outfile = "/tmp/user-data.ps1"
        else
            outfile = "/tmp/user-data.txt"
        end
        system "cp #{ufile} #{outfile}"
        cmd = ""
        if File.exist?("#{outfile}")
            cmd = "sed -i \"s/HNAME/#{hname}/g\" #{outfile}" 
            `#{cmd}`
            if ( os1. upcase != "WINDOWS")
                cmd = "sed -i '7iecho \"#{sshkey}\" >> /root/.ssh/authorized_keys' #{outfile}"
                `#{cmd}`
            end
        else
            puts "user data file is not exists, please check whether you have template file /home/WATERFRONTMEDIA/sraju/eh/user-data-linux.sh"
            exit 
        end
        return "#{outfile}"
    end

    def generateAWSQuery(pkey,subnet,sgroup,size,ami,ufile,osinfo)
        if ( osinfo.upcase == "WINDOWS")
            query1="aws ec2 run-instances --image-id AMIID --key-name KEYNAME --security-group-ids GROUPIDS --user-data file://UFILE --instance-type INSTYPE --subnet-id SUBNETID " #--associate-public-ip-address
        elsif ( osinfo.upcase == "LINUX")
            query1="aws ec2 run-instances --image-id AMIID --key-name KEYNAME --security-group-ids GROUPIDS --user-data file://UFILE --instance-type INSTYPE --subnet-id SUBNETID --associate-public-ip-address" #--associate-public-ip-address
        end
        grp =""
        sgroup.each { |groupid|
            grp = grp + "\"#{groupid}\" "
        }
        query1 ["AMIID"] = ami
        query1 ["KEYNAME"] = pkey
        query1 ["GROUPIDS"] = grp
        query1 ["INSTYPE"] = size
        query1 ["SUBNETID"] = subnet
        query1 ["UFILE"] = ufile
        return query1
    end

    def createInstance(cquery)
        #puts "#{cquery}"
        intID = ""
        intIP = ""
        out1 = `#{cquery}`
        obj = ""
        if out1.include? "Error 500"
            puts "Not able to get requested details "
            intID="ERR"
        else
            if out1.length > 10
               obj = JSON.parse(out1) 
               if obj['Instances'].any?
                    intID=obj['Instances'][0]['InstanceId']
                else
                    intID="ERR1"
                end
            else
                intID="ERR2"
            end
        end    
        return intID
    end

    def getInstanceIP (intID)
        cmd="aws ec2 describe-instances --instance-ids #{intID}"
        stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        str = stdout1.read
        stat=0
        if str.include? "Error 500"
            puts "Didn't found requested instanaces"
            exit
        else
            obj = JSON.parse(str)
        end

        if obj['Reservations'].any?
            intIP=obj['Reservations'][0]['Instances'][0]['PrivateIpAddress']
        else
            stat=1
        end
        return stat,intIP
    end

    def generateAWSTags(hname,intid,proj,role,os,envir)
        if envir == "prod"
            env1 = "Production"
        else
            env1 = "Staging"
        end
        stat = 0
        q1 = "aws ec2 create-tags --resources #{intid} --tags Key=Name,Value=#{hname}"
        q2 = "aws ec2 create-tags --resources #{intid} --tags Key=environment,Value=#{env1}"
        q3 = "aws ec2 create-tags --resources #{intid} --tags Key=role,Value=#{role}"    
        intID = ""
        #stdout1 = StringIO.new
        out1 = `#{q1};#{q2};#{q3};#{q4}`
        if out1.include? "Error 500"
            puts "Not able to get requested details "
            stat = 2
        else
            stat = 1
        end
        return stat
    end

    def checkAMI(size,ami)
        cmd = "aws ec2 describe-images --image-ids #{ami}"
        stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        str = stdout1.read
        stat=0
        if str.include? "Error 500"
            puts "Didn't found requested AMI Images #{ami}"
            exit
        else
            obj = JSON.parse(str)
        end
        if obj['Images'].any?
            intst=obj['Images'][0]['State']
        else
            stat=1
        end
        return stat,intst
    end

    def syncContent(hname,proj,role,os,envir,spath,intIP,subv)
        mptserver = {"mptwebstg" => "172.31.68.92" , "mptwebprod" => "172.31.91.188", "mptcfstg" => "172.31.68.233" , "mptcfprod" => "172.31.95.110"}
        ehserver = {"ehstg" => "172.31.70.197" , "ehprod" => "172.31.91.188"}
        lpath = "/mnt/deployment/mpt/#{envir}/#{role}/"
        spath.chomp
        if ( role == "web" and os.upcase == "LINUX")
            if ( proj == "mpt" and envir == "stage")
                serverIP = mptserver["mptwebstg"]
                cmd = "rsync -av --exclude-from '#{spath}mpt-exclude-list' -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" root@#{serverIP}:/var/web/www.medpagetoday.com/content #{lpath}"
                stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
                str = stdout1.read
                cmd1 = "rsync -av  -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" #{lpath}content root@#{intIP}:/var/web/www.medpagetoday.com/"
                stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd1}")
                str = stdout1.read
                if (subv == 0)
                    cmd2 = "rsync -av -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" #{lpath}/db.php-zone1 root@#{intIP}:/var/web/www.medpagetoday.com/content/protected/config/db.php"
                else
                    cmd2 = "rsync -av -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" #{lpath}/db.php-zone2 root@#{intIP}:/var/web/www.medpagetoday.com/content/protected/config/db.php"
                end
                #puts "#{cmd2}"
                stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd2}")
                str = stdout1.read
                cmd3 = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@#{intIP} \"chown -R nobody:nobody /var/web/www.medpagetoday.com\""
                stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd3}")
                str = stdout1.read
            elsif (proj == "mpt" and envir == "prod")
                serverIP = mptserver["mptwebprod"]
                cmd = "rsync -av --exclude-from '#{spath}mpt-exclude-list' -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" root@#{serverIP}:/var/web/www.medpagetoday.com/content #{lpath}"
            end
        elsif ( role == "cf" and os.upcase == "LINUX")
            if ( proj == "mpt" and envir == "stage")
                serverIP = mptserver["mptcfstg"]
                cmd2 = "rsync -av -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" #{lpath}/neo-datasource.xml root@#{intIP}:/var/web/www.medpagetoday.com/content/protected/config/db.php"
                stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd2}")
                str = stdout1.read
                if ( envir == "stage" )          
                    efile = "environments_staging.cfc"
                elsif ( envir == "prod" )
                    efile = "environments_prod.cfc"
                else
                    efile = "environments_qa.cfc"
                end
                cmd="ln -s /var/web/medpagetoday.com/content/lib/components/#{efile} /var/web/medpagetoday.com/content/lib/components/environments.cfc"
                system(cmd)
             
            elsif (proj == "mpt" and envir == "prod")
                serverIP = mptserver["mptcfprod"]
                cmd = "rsync -av --exclude-from '#{spath}mpt-exclude-list' -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" root@#{serverIP}:/var/web/www.medpagetoday.com/content #{lpath}"
            end
        elsif (role == "web" and os.upcase == "WINDOWS")
            dIP = intIP
            if (envir.upcase == "STAGE")
                sIP =  ehserver['ehstg']
            elsif (envir.upcase == "PROD")
                sIP =  ehserver['ehprod']
            else
                sIP =  ehserver['ehstg']        
            end
            stat=loginDeploySys(sIP,dIP)
        end
    end

    def loginDeploySys(sIP,dIP)
        spath = "/mnt/source"
        dpath = "/mnt/dest"
        stat = ""
        user="Administrator"
        spassword="4H3@lthyL1f3"

        dpassword="Sr&jLxMHWq;"

        scmd="mount -t cifs -o username=#{user},password='#{spassword}',domain=WATERFRONTMEDIA.NET //#{sIP}/D$/websites #{spath}"
        dcmd="mount -t cifs -o username=#{user},password='#{dpassword}' //#{dIP}/D$ #{dpath}"

        sleep 5
        smount=`mount | grep #{sIP} |wc -l |tr -d '\n'`
        dmount=`mount | grep #{dIP} |wc -l |tr -d '\n'`

        if smount == "0"
            system (scmd)
        end

        if dmount == "0"
            system (dcmd)
        end

        sm1=`mount | grep #{sIP} |wc -l |tr -d '\n'`
        dm1=`mount | grep #{dIP} |wc -l |tr -d '\n'`

puts "#{sm1} ----- #{dm1}"
        if (sm1 == "0" && dm1 == "0")
            stat = "ERR"
        else
            if Dir.exists?("/mnt/dest/websites")
            else
                `mkdir /mnt/dest/websites`
            end
            puts "Copying Content into server"
            cmd="cp -r /mnt/source/* /mnt/dest/websites/"
            system (cmd)
            puts "Completed content copy "
            cmd="umount -l #{dpath} "
            system (cmd)
            cmd="umount -l #{spath}"
            system (cmd)
        end
        return stat
    end

    def loginWindowsSys(serverIP)
        opts = { 
        endpoint: "http://#{serverIP}:5985/wsman",
        user: 'administrator',
        password: 'Sr&jLxMHWq;'
        }

        conn = WinRM::Connection.new(opts)
        return conn
    end

    def installWindowsModules(serverIP,fname)
        conn = loginWindowsSys(serverIP)

        chostname=""
        conn.shell(:powershell) do |shell|
            output = shell.run('hostname') do |stdout, stderr|
                stdout.chomp
                chostname=stdout.chomp
                STDOUT.print stdout
                STDERR.print stderr
            end
        end

        conn.shell(:powershell) do |shell|
            output = shell.run('mkdir C:\scripts') do |stdout, stderr|
#                STDOUT.print stdout
#                STDERR.print stderr
            end
        end

        system "cp /home/WATERFRONTMEDIA/sraju/eh/user-data-windows-s1.ps1 /home/WATERFRONTMEDIA/sraju/eh/user-data-windows-s2.ps1 /tmp/"
        outfile = "/tmp/user-data-windows-s1.ps1"
        if File.exist?("#{outfile}")
            cmd = "sed -i \"s/HNAME/#{fname}/g\" #{outfile}" 
            `#{cmd}`
        else
            puts "user data file is not exists, please check whether you have template file /home/WATERFRONTMEDIA/sraju/eh/user-data-windows-s1.ps1"
            exit 
        end
        outfile = "/tmp/user-data-windows-s2.ps1"
        if File.exist?("#{outfile}")
            cmd = "sed -i \"s/HNAME/#{fname}/g\" #{outfile}" 
            `#{cmd}`
        else
            puts "user data file is not exists, please check whether you have template file /home/WATERFRONTMEDIA/sraju/eh/user-data-windows-s2.ps1"
            exit 
        end

        file_manager = WinRM::FS::FileManager.new(conn)
        file_manager.upload(['/tmp/user-data-windows-s1.ps1','/tmp/user-data-windows-s2.ps1'], 'c:/scripts/')

        file_manager = WinRM::FS::FileManager.new(conn)
        file_manager.upload('/home/WATERFRONTMEDIA/sraju/eh/AdvancedLogging64.msi', 'c:/scripts/')


        if fname.include?(chostname.downcase) 
            puts "Hostname is same in server : #{chostname}"
        else
            conn.shell(:powershell) do |shell|
                output = shell.run('C:\scripts\user-data-windows-s1.ps1') do |stdout, stderr|
#                    STDOUT.print stdout
                    STDERR.print stderr
                end
            end

            puts "Changed the hostname and rebooting the server .."
            sleep 10
            status = "down"
            while status != "up"
                print "."
                sleep 3
                cmd = "nc -zv -w 3 #{serverIP} 5985 | grep 'Connection' |wc -l | tr -d '\\n'"
                stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
                val1 = stdout1.read
                val1.chomp
                if val1 == "1"
                    status = "up"
                else
                    status = "down"
                end
            end    
        end
        mstat=""
        conn.shell(:powershell) do |shell|
            output = shell.run('(Get-WindowsFeature -name Web-WebServer).Installed') do |stdout, stderr|
                mstat=stdout.chomp
 #               STDOUT.print stdout
                STDERR.print stderr
            end
        end
        if mstat != "True"
            puts "Installing Windows Modules, Puppet and IIS  .."
            conn.shell(:powershell) do |shell|
                output = shell.run('C:\scripts\user-data-windows-s2.ps1') do |stdout, stderr|
                #output = shell.run('hostname') do |stdout, stderr|
                #STDOUT.print stdout
                STDERR.print stderr
                end
            end

            puts "Installed IIS and other Modules and restarting .."
            sleep 10
            status = "down"
            while status != "up"
                print "."
                sleep 3
                cmd = "nc -zv -w 3 #{serverIP} 5985 | grep 'Connection' |wc -l | tr -d '\\n'"
                stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
                val1 = stdout1.read
                val1.chomp
                if val1 == "1"
                    status = "up"
                else
                    status = "down"
                end
            end

        else
            puts "Server already have IIS installed on it"
        end


        puts "Running puppet on server to configure IIS"
        sleep 10
        conn.shell(:powershell) do |shell|
            output = shell.run('puppet agent -t') do |stdout, stderr|
#                STDOUT.print stdout
                STDERR.print stderr
            end
        end

        conn.shell(:powershell) do |shell|
            output = shell.run('puppet agent -t') do |stdout, stderr|
#                STDOUT.print stdout
                STDERR.print stderr
            end
        end

        conn.shell(:powershell) do |shell|
            output = shell.run('puppet agent -t') do |stdout, stderr|
#                STDOUT.print stdout
                STDERR.print stderr
            end
        end
    end


    def startInstance(intid)
        intst=getInstanceStatus(options[:intname])
        if intst == 'running' 
            puts "Requested Instance #{options[:intname]} is already running state"
        else
            cmd = "aws ec2 start-instances --instance-ids #{intid} "
            stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
            str = stdout1.read
            if str.include? "Error 500"
                puts "Not able to get requested details "
            else
                obj = JSON.parse(str)
            end
            puts " Starting #{options[:intname]} now ...... "
            status = "stopped"
            while status != "running" do
                print "."
                sleep 2
                status=getInstanceStatus(options[:intname])
            end
            print "\n #{options[:intname]} is started now \n"
        end
    end

    def stopInstance(intid)
        intst=getInstanceStatus(options[:intname])
        if intst == 'stopped' 
            puts "Requested Instance #{options[:intname]} is already stopped state"
        else
            cmd = "aws ec2 stop-instances --instance-ids #{intid} "
            stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
            str = stdout1.read
            if str.include? "Error 500"
                puts "Not able to get requested details "
            else
                obj = JSON.parse(str)
            end
            puts " Stopping #{options[:intname]} now ...... "
            status = "running"
            while status != "stopped" do
                print "."
                sleep 2
                status=getInstanceStatus(options[:intname])
            end
            print "\n #{options[:intname]} is stopped now \n"
        end
    end

    def getInstanceStatus(intname)
        cmd = "aws ec2 describe-instances --filters Name=tag-value,Values=#{intname} --region us-east-1"
        stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        str = stdout1.read
        if str.include? "Error 500"
            puts "Not able to get requested details "
        else
            obj = JSON.parse(str)
        end
        if obj['Reservations'].any?
            intst=obj['Reservations'][0]['Instances'][0]['State']['Name']
            return intst
        else
            puts "Requested instance #{intname} not found in this AWS "
            exit
        end
    end

    def getInstanceID(intname)
        cmd = "aws ec2 describe-instances --filters Name=tag-value,Values=#{intname} --region us-east-1"
        stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        str = stdout1.read
        if str.include? "Error 500"
            puts "Not able to get requested details "
        else
            obj = JSON.parse(str)
        end
        if obj['Reservations'].any?
            intid=obj['Reservations'][0]['Instances'][0]['InstanceId']
            return intid
        else
            puts "Requested instance #{intname} not found in this AWS "
            exit
        end
    end

    def getInstanceInfo(intname)
        cmd = "aws ec2 describe-instances --filters Name=tag-value,Values=#{intname} --region us-east-1"
        stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        str = stdout1.read
        if str.include? "Error 500"
            puts "Not able to get requested details "
        else
            obj = JSON.parse(str)
        end
        if obj['Reservations'].any?
            intid=obj['Reservations'][0]['Instances'][0]['InstanceId']
            intst=obj['Reservations'][0]['Instances'][0]['State']['Name']
            intprip=obj['Reservations'][0]['Instances'][0]['PrivateIpAddress']
            intpuip=obj['Reservations'][0]['Instances'][0]['PublicIpAddress']
            intkey=obj['Reservations'][0]['Instances'][0]['KeyName']
            intintype=obj['Reservations'][0]['Instances'][0]['InstanceType']
            puts "Instance ID | Instance Name | Status | Private IP | Public IP | Server Key | Instance Type "
            puts "#{intid} | #{intname} | #{intst} | #{intprip} | #{intpuip} | #{intkey} | #{intintype} "
        else
            puts "Requested instance #{intname} not found in this AWS "
            exit
        end
    end
 
    def getAllInstance()
        cmd = "aws ec2 describe-instances --region us-east-1"
        stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        str = stdout1.read
        if str.include? "Error 500"
            puts "Not able to get requested details "
        else
            obj = JSON.parse(str)
        end
        if obj['Reservations'].any?
            puts "Instance ID | Instance Name | Status | Private IP | Public IP | Server Key | Instance Type | Project | Environment | Role |"
            array = obj['Reservations']
            array.each {|hash|
                intname=""
                intnameproj=""
                intnameevr=""
                intnamerole=""
                intid=hash['Instances'][0]['InstanceId']
                arr1 = hash['Instances'][0]['Tags']
                arr1.each {|tags|
                if tags['Key'] == 'Name'
                    intname=tags['Value']
                end
                if tags['Key'] == 'Project'
                    intnameproj=tags['Value']
                end
                if tags['Key'] == 'Environment'
                    intnameevr=tags['Value']
                end
                if tags['Key'] == 'Role'
                    intnamerole=tags['Value']
                end
            }
            intst=hash['Instances'][0]['State']['Name']
            intprip=hash['Instances'][0]['PrivateIpAddress']
            intpuip=hash['Instances'][0]['PublicIpAddress']
            intkey=hash['Instances'][0]['KeyName']
            intintype=hash['Instances'][0]['InstanceType']
            puts "#{intid} | #{intname} | #{intst} | #{intprip} | #{intpuip} | #{intkey} | #{intintype} | #{intnameproj} | #{intnameevr} | #{intnamerole}  | "
        }               
        else
            puts "Didn't found any instanace currently on this account "
            exit
        end
    end

    def getSubnetDetails(cc,role,env,asubnet)
        subv = cc.to_i % 2
        if (subv == 1 && role == "db" && env == "prod")
            subnet = asubnet["db1"]
        elsif (subv == 0 && role == "db" && env == "prod" )
          subnet = asubnet["db2"]
        elsif (subv == 1 && role == "db" && env == "stage" )
          subnet = asubnet["stgdb1"]
        elsif (subv == 0 && role == "db" && env == "stage" )
            subnet = asubnet["stgdb2"]    
        elsif (subv == 1 &&  env == "stage" )
          subnet = asubnet["stgweb1"]    
        elsif (subv == 0 &&  env == "stage" )
          subnet = asubnet["stgweb2"]    
        elsif (subv == 1 )
          subnet = asubnet["web1"]
        elsif (subv == 0 )
          subnet = asubnet["web2"]  
        else
          puts "Didn't found any subnet for this project, please check pass correct parameters"
          exit 0
        end
        return subnet
    end

    def generateBackend(intIP,hname,project,role,os,env)
        proj = project.upcase
        rol1 = role.downcase
        if ((hname =~ /awse/) && (env == "stage"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/awse_stage/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/awse_stage/"
        elsif ((hname =~ /awse/) && (env == "prod"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/awse_prod/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/awse_prod/"
        elsif ((hname =~ /usnj/) && (env == "stage"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/stage/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/stage/"
        elsif ((hname =~ /usnj/) && (env == "prod"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/prod/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/prod/"
        elsif ((hname =~ /usnj/) && (env == "dev"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/dev/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/dev/"
        elsif ((hname =~ /usnj/) && (env == "qa1"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/qa1/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/qa1/"
        elsif ((hname =~ /usnj/) && (env == "qa2"))
            svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish%204.0/#{proj}/backends/qa2/"
            locpath="/mnt/deployment/varnish40/#{proj}/backends/qa2/"
        else
            return "ERR"
        end

        cmd = "mkdir -p #{locpath}; svn co #{svnpath} #{locpath}"
        stdin1, stdout1, stderr1, wait_thr1 = Open3.popen3("#{cmd}")
        str = stdout1.read
        rfile = "#{locpath}mpt_backends.vcl"
        
        cmd = "grep 'backend mpt_homepage' #{rfile} |cut -d' ' -f2|cut -d'{' -f1 |wc -l"
        bcc = `#{cmd}`.to_i
        bcc = bcc + 1
        if ( bcc < 10 )
          backend = "mpt_homepage_0#{bcc}"
        else
          backend = "mpt_homepage_#{bcc}"
        end
        str = "backend BNAME{\\n     .host = \"SERVERIP\";\\n     .port = \"80\"; \\n     .connect_timeout = 1.5s;\\n     .host_header = \"SITEURL\";\\n     .probe = {\\n         .url = \"/status.html\";\\n         .interval = 15s;\\n         .timeout = 180 s;\\n         .window = 5;\\n         .threshold = 5;\\n    }\\n}\\n\\n"

        str["BNAME"] = "#{backend}"
        str["SERVERIP"] = "#{intIP}"
        str["SITEURL"] = "staging.medpagetoday.com"

        if `grep '#{intIP}' #{rfile} |wc -l | xargs  |tr -d '\n'` == "0"
            cmd = "sed -i '/vcl_init/ i #{str}' #{rfile}"
            system(cmd)
            vinitstr="   mpt_homepage_dir.add_backend(BNAME, 1);"
            vinitstr["BNAME"] = "#{backend}"

            cmd = "sed -i 's/new mpt_homepage_dir.*/new mpt_homepage_dir = directors.hash();\\n     #{vinitstr}/g' #{rfile}"
            system (cmd)
            return  "created"
        else
            return "exist"            
        end
    end

    def varnishUpdates(intIP,proj,role,os,env,vacIP)
        ehvarnish = EHVarnishAutomationClass.new
        gname = "#{proj}_#{env}"
        gdesc = "This is for #{proj}.upcase #{env}"
        gid=""
        groupid = ehvarnish.getGroupID(gname,vacIP)
        if groupid == "ERR"
            gid = ehvarnish.createGroup(gname,gdesc,vacIP)
            #puts "#{gid}"
        end
        groupid = ehvarnish.getGroupID(gname,vacIP)

        cachestr = ehvarnish.getCacheServerID(intIP,vacIP)
        gname1,cacheid,serverIP = cachestr.split(":")
        #puts "#{groupid} -- #{cacheid}"
        if gname1["all"]
            if ehvarnish.addServertoGroup(groupid,cacheid,vacIP)
                puts "Server is successfull deployed in to #{gname} group"
            else
                puts "Failed to deploy #{serverIP} to #{gname}"
                exit 0
            end
        else
            puts "Server is already in #{gname} Cache Group"
        end

        vname = "#{proj}_#{env}40"
        vclid=ehvarnish.createVCLs(vname,'Testing VCL',vacIP)
        #result=ehvarnish.displayVCLs(vacIP)
        #result.each { |key,value| 
        #    puts "#{key}=>#{value}" 
        #}

        gname1,vclID,vclname=ehvarnish.getVCLs(vname,vacIP).split(":")
        filename="/home/WATERFRONTMEDIA/sraju/eh/#{vname}"
        depID=ehvarnish.deployVCLs(vname,vclID,filename,vacIP)

        if ehvarnish.deployVCLtoGroup(groupid,vclID,vacIP)
            cmd = "ssh root@#{intIP} \"ls -lh /var/lib/varnish-agent/boot.vcl |wc -l | xargs  |tr -d '\n'\""
            va1 = `#{cmd}`
            if ( va1 == "1" )
                cmd1 = "ssh root@#{intIP} \"sed -i 's/^VARNISH_VCL_CONF.*/VARNISH_VCL_CONF=\\/var\\/lib\\/varnish-agent\\/boot.vcl/g' /etc/sysconfig/varnish\""
                system (cmd1)

                cmd1 = "ssh root@#{intIP} \"service varnish status; service varnish-agent status\""
                system (cmd1)
            else
                puts "Deployment faile and not boot.vcl file"
            end
        else
            puts "Failed to deploy to group"
        end
    end
end