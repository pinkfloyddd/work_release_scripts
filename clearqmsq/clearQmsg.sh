#!/usr/bin/ksh
clearqmsg(){
echo "check process status"
while true
    do
        LogFile=/home/rmbmtr1/Live/Compile/Log/LM_MTS/Log.UserOnlProcMaintSystem
        ProcessNum=$(ps -fu rmbmtr1|grep UserOnlProcMaintSystem | grep -v grep | wc -l)
        if [ ! -e $LogFile -a $ProcessNum != 1 ]
        then
            echo "process not running";
            sleep 60
        else
            echo "process is running\n"
            sleep 30
            echo "running ReadQmsg first"
            /home/mqm/ReadQmsg 1 Qlist.txt >> Log.ReadQmsg
            break
        fi
    done
sleep 10
echo "running ReadQmsg second\n"
/home/mqm/ReadQmsg 1 Qlist.txt >> Log.ReadQmsg
echo "waitting for log flag\n"
sleep 20
for i in `awk -F " " '{print $2}' chlist2`
    do
        echo "check $i depth in log"
        Logflag1=$(tail -10 /home/rmbmtr1/Live/Compile/Log/LM_MTS/Log.UserOnlProcMaintSystem | grep $i)
        Logflag2=$(grep "Suceesfully Completed UserOnlProc" /home/rmbmtr1/Live/Compile/Log/LM_MTS/Log.UserOnlProcMaintSystem|awk -F " " '{print $7}')
        CMD=$(sed -n '/'"$i"'/p' chlist2)
        if [ "$Logflag2" == "{Suceesfully" -a "$Logflag1" == " "  ]
        then
            echo "clear msg done\n"
        elif [ "$Logflag1" !=" " ]
        then
            echo "check $i depth not ok\n"
            $CMD
            sleep 5 
        else
            echo "run ReadQmsg again\n"
            /home/mqm/ReadQmsg 1 Qlist.txt >> Log.ReadQmsg
        fi
    done
echo "sleep 7min"
sleep 420 
SUCCESSFLAG=$(grep "Suceesfully Completed UserOnlProc" /home/rmbmtr1/Live/Compile/Log/LM_MTS/Log.UserOnlProcMaintSystem|awk -F " " '{print $7}')
if [ $SUCCESSFLAG=="{Suceesfully" ]
then
    echo "clear msg successfully"
else
    /usr/mqm/samp/bin/amqsget TO_API_FE MTSQM0 >> /home/mqm/TO_API_FE.txt
    /usr/mqm/samp/bin/amqsget TO_API_EH MTSQM0 >> /home/mqm/TO_API_EH_1_msg.txt
    /usr/mqm/samp/bin/amqsget TO_BCQMKTINFRMN_RSPN  MTSQM0 >> TO_BCQMKTINFRMN_RSPN_1.txt
    /usr/mqm/samp/bin/amqsget TO_BCQMKTINFRMN_RSPN2 MTSQM0 >> TO_BCQMKTINFRMN_RSPN2_1.txt
    /usr/mqm/samp/bin/amqsget TO_RESPSERV_0 MTSQM2 >> TO_RESPSERV_0_1.txt
    /usr/mqm/samp/bin/amqsget TO_ADAPTORREV_2 MTSQM0 >> /home/mqm/TO_ADAPTORREV_2.txt
    /usr/mqm/samp/bin/amqsget TO_SHMSYNC_1 MTSQM0 >> /home/mqm/TO_SHMSYNC_1.txt
    /usr/mqm/samp/bin/amqsget TO_WINDOWSSERVER_1 MTSQM0 >> /home/mqm/TO_WINDOWSSERVER_1.txt
fi
}
BSNSCHK=$(echo 'select count(*) from trdx_bsns_date_dtls bdd where bdd.bdd_bsns_date=trunc(sysdate);' | sqlplus onl1/onl1@train_103 |sed -n '14p'|awk -F ' ' '{print $1}')
echo $BSNSCHK
if [ $BSNSCHK -gt 0 ]
then
	echo "###################################"
	date && echo "today is bussiness day"
	clearqmsg
else
	echo "##################################"
	date && echo "today is not business day"	
fi
