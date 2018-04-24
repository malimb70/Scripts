#!/bin/sh

tdate=`date +"%y%m%d-%H%M"`
FILE="/home/WATERFRONTMEDIA/siege/${project}/${environment}/${filename}"
sub=""
mess=""
result=0
if [ -f $FILE ]; then
    mess=`siege -v -c $users -t5m -f $FILE 2> /tmp/result_${tdate}.log | tee /tmp/output_${tdate}.txt`    
    sub="Siege Test Success"
    result=0
else
    mess="${FILE} is not existing"
    echo "message: ${mess}" > /tmp/result_${tdate}.log
    sub="Siege Test Failed"
    result=1
fi

MEmailMessage="/tmp/mptmainmessage.txt"
echo "" > $MEmailMessage
echo "<html> " >> $MEmailMessage
echo "<head>" >> $MEmailMessage
echo "        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />" >> $MEmailMessage
echo "        <meta http-equiv="Content-Language" content="en" />" >> $MEmailMessage
echo "</head>" >> $MEmailMessage
echo "<body>" >> $MEmailMessage
#echo "<p><table border=1 cellpadding=2 cellspacing=2>" >> $MEmailMessage

while read line; do
    echo "${line} <br>" >> $MEmailMessage
done < /tmp/result_${tdate}.log

echo "</body></html>" >> $MEmailMessage

(
echo "To: ${email}"
echo "From: siege@everydayhealthinc.com"
echo "Subject: ${sub}"
echo "Content-Type: text/html"
echo
cat $MEmailMessage
echo
) | /usr/sbin/sendmail -t

exit $result
