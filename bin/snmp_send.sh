#   (C) Copyright 1997-2012 hSenid Software International (Pvt) Limited.
#   All Rights Reserved.
#
#   These materials are unpublished, proprietary, confidential source code of
#   hSenid Software International (Pvt) Limited and constitute a TRADE SECRET
#   of hSenid Software International (Pvt) Limited.
#
#   hSenid Software International (Pvt) Limited retains all title to and intellectual
#   property rights in these materials.
#########################################################################################
#       Product                 : DST GR
#       Component               : 
#       Script File Name        : 
#       Script Location         :
#       Author                  : Kasun     
#       Date                    :           
#       Version                 :
#########################################################################################
#       Cron Details            :  
#       
#########################################################################################
#       Description             : snmp sender script used by all the modules                                         
#                                                                    
#                      
#       
#         
#               
#       Sample usage            : 
#               
#
#########################################################################################

#!/bin/bash

OID=`echo "$1"|cut -d\| -f1`
OID1=`echo $OID|cut -d\. -f2`
OID2=`echo $OID|cut -d\. -f3`
OID3=`echo $OID|cut -d\. -f4`
OID=$OID1.$OID2.$OID3
CRTICALITY=`echo "$1"|cut -d\| -f2`
MESSAGE=`echo "$1"|cut -d\| -f3`
CUR_DATE=`date +%Y-%m-%d`

echo `date +%F_%H-%M-%S`  "  $OID"-"$CRTICALITY"-"$MESSAGE" >>../logs/snmp.log.$CUR_DATE
HOST=`uname -n`
#snmptrap -d -v2c -c private 192.168.78.140 '' HMS-SNMP-MIB::hms.$OID private.$OID s "$MESSAGE"
#wget --delete-after --post-data="message=$HOST-$MESSAGE&recipient-address=94773687964&encoding=0&app-id=APP_000000&correlation-id=1317111628394&operator=dialog&sender-address=Dialog" http://192.168.30.11:8000/sms/send >>/dev/null 2>&1 
