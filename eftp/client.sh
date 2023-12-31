#!/bin/bash

echo $#

if [ $# = 0 ] 
then 
	SERVER="localhost"
elif [ $# -ge 1 ]
then 
	SERVER=$1
fi 

IP=`ip address | grep inet | grep enp0s3 | cut -d " " -f 6 | cut -d "/" -f 1`
PORT=3333

if [ $# -eq 2 ]
then
	echo "(-1) Reset"
	echo "Reset" | nc $SERVER $PORT
	
	sleep 2
fi


echo "EFTP 1.0" $IP | nc $SERVER $PORT
TIMEOUT=1
echo "Cliente de EFTP"

echo "(1) Send"
echo "EFTP 1.0 $IP" | nc $SERVER $PORT

echo "(2) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA
sleep 1

echo "(5) Test & Send"
if [ "$DATA" != "OK_HEADER" ]
then 
	echo "ERROR 1: BAD HEADER"
	exit 1
fi
echo "OK_HEADER"
echo "BOOOM"
sleep 1 
echo "BOOOM" | nc $SERVER $PORT

echo "(6) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA
sleep 1

echo "(9) Test"
if [ "$DATA" != "OK_HANDSHAKE" ]
then
	echo "ERROR 2: BAD HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc $SERVER $PORT
	exit 2
fi
sleep 1

echo "(9a)" SEND NUM FILES
NUM_FILES=`ls imgs/ | wc -l`
sleep 1
echo "NUM_FILES $NUM_FILES" | nc $SERVER $PORT

echo "(9b) Listen OK/KO NUM FILES" 
DATA=`nc -l -p $PORT -w $TIMEOUT`
if [ "$DATA" != "OK_FILE_NUM"  ]
then
	echo "ERROR 3a: WRONG FILE NUM"
	exit 3
fi

for FILE_NAME in `ls imgs/`
do

echo "(10b) Send FILE NAME"

sleep 1
#FILE_NAME="fary1.txt"
FILEMD5=`echo "$FILE_NAME" | md5sum | cut -d " " -f 1`
echo "FILE_NAME $FILE_NAME $FILEMD5" | nc $SERVER $PORT
sleep 1

echo "(11) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA
sleep 1
echo "(14) Test & Send" 
if [ "$DATA" != "OK_FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE_NAME"
	exit 3
fi 
sleep 1
cat imgs/"$FILE_NAME" | nc $SERVER $PORT
echo "(15) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(18) Test & Send"

if [ "$DATA" != "OK_DATA" ]
then
	echo "ERROR 4: BAD DATA"
	exit 4
fi

echo "(18) Send"
FILE_MD5=`cat imgs/fary1.txt | md5sum | cut -d " " -f 1`
echo "FILE_MD5 $FILE_MD5" | nc $SERVER $PORT

echo "(19) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo "$DATA"

echo "(21) Test"
if [ "$DATA" != "OK_FILE_MD5" ]
then
	echo "ERROR: FILE MD5"
	exit 5
fi

done
echo "FIN"
exit 0
