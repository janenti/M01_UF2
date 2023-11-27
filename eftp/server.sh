CLIENT=`ip a | grep inet | head -n 3 | tail -n 1 | cut -d " " -f 6 | cut -d "/" -f 1`
PORT=3333
TIMEOUT=1
echo "Servidor de EFTP"

echo "(0) Listen"
DATA=`nc -l -p $PORT  -w $TIMEOUT`
echo $DATA

echo "(3) Test & Send"
if [ "$DATA" != "EFTP 1.0" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1
fi

echo "OK_HEADER"
sleep 1 
echo "OK_HEADER" | nc $CLIENT $PORT

echo "(4) Listen"
DATA=`nc -l -p $PORT  -w $TIMEOUT`


echo "(7) Test & Send (Handshake)"
if [ "$DATA" != "BOOOM" ]
then
	echo "ERROR 2: BAD HANDSHAKE"
	sleep 1
	echo "BAD_HANDSHAKE" | nc $CLIENT $PORT
	exit 2
fi

sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT $PORT

echo "(8) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(12) Test & Store & Send"
PREFIX=`echo $DATA | cut -d " " -f 1`
if  [ "$PREFIX" != "FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE NAME PREFIX"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT 3333
	exit 3
fi

FILE_NAME=`echo "$DATA" | cut -d " " -f 2`
FILE_MD5=`echo "$DATA" | cut -d " " -f 3`
MD5_LOCAL=`echo "$FILE_NAME" | md5sum | cut -d " " -f 1 `

echo "Testing Hash"
if [ "$FILE_MD5" != "$MD5_LOCAL" ]
then
	echo "Error 3:BAD FILE MD5"
	sleep 1
	echo "KO_FILE_NAME" | nc "$CLIENT" 3333
	exit 3
fi

DATA=`cat inbox/$FILE_NAME `

echo "OK_FILE_NAME" | nc $CLIENT $PORT

echo "(13)Listen"
DATA=`nc -l -p $PORT  -w $TIMEOUT`

echo "(16) Store & Send"
if [ "$DATA" == "" ]
then
	echo "Error 4: EMPTY DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
	exit 4
fi

echo $DATA > inbox/$FILE_NAME

sleep 1
echo "OK_DATA" | nc $CLIENT 3333

echo "(17) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "Fin"
exit 0
