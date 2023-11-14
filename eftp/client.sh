#!/bin/bash
SERVER="10.65.0.67"
PORT=3333
IPCLIENT=`ip a | grep inet | head -n 3 | tail -n 1 | cut -d " " -f 6 | cut -d "/" -f 1`
echo "Cliente de EFTP"

echo "(1) Send"
echo "EFTP 1.0 $IPCLIENT" | nc $SERVER $PORT

echo "(2) Listen"
DATA=`nc -l -p $PORT -w 0`
echo $DATA

echo "(5) Test & Send (Handshake)"
if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 1: BAD HEADER"
	echo "KO_HEADER"
	exit 1
fi

echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER $PORT

echo "(6) Listen"
DATA=`nc -l -p $PORT -w 0`
echo $DATA

echo "(9) test"
if [ "$DATA" != "OK_HANDSHAKE"  ]
then
	echo "Error 2: BAD HANDSHAKE"
	echo "BAD_HANDSHAKE"
	exit 2
fi

sleep 1
echo "(10) Send"
echo "FILE_NAME fary1.txt" | nc $SERVER $PORT

echo "(11) Listen"
DATA=`nc -l -p $PORT -w 0`
echo $DATA

echo "(14) Test & Send"
if [ $DATA != "OK_FILE_NAME" ]
then
	echo "Error 3: BAD FILE NAME PREFIX"
	exit 3
fi
sleep 1
cat imgs/fary1.txt | nc $SERVER $PORT

echo "(15) Listen"
DATA=`nc -l -p $PORT -w 0`

