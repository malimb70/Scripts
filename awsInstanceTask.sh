#/bin/bash

if [ $# -eq 0 ]
then
   echo "Need to pass two agruments [task] [filename with list of aws instance names]"
   echo "example : sh awsInstanceTask.sh [start/stop/info] /tmp/vmlist.txt"
   exit 0
else
   if [[ ( "$1" = "start" || "$1" = "stop" || "$1" = "info" ) && ( -f $2 ) ]]
   then
        for i in `cat $2 `; do /usr/local/bin/awsEHClitool.rb -t $1 -i $i; done
   else
        echo "Need to pass correct agruments"
        echo "example : sh awsInstanceTask.sh [start/stop/info] /tmp/vmlist.txt"
   fi
fi

