#!/bin/bash

APIKEY=AJVPJ3FMMP2EYRD8AUTAI9HET3DVADC986

RESPONSE=$(curl "http://api.etherscan.io/api?module=stats&action=ethprice&apikey=${APIKEY}" 2>/dev/null)
if ( grep '"status":"1","message":"OK"' <<< "$RESPONSE" >/dev/null )
then
	ETHERPRICE=$(sed -e 's/.*"ethusd":"\([0-9.]\+\)","ethusd_timestamp":"\([0-9]\+\)".*/\1/' <<< "$RESPONSE")
	echo -e "Got Ethereum price \e[1m${ETHERPRICE}\e[0m"
	truffle --network development exec update-ether-price.js $ETHERPRICE
else
	echo "Error: $RESPONSE" > /dev/stderr
fi

 
