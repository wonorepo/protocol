#!/bin/sh

. ./config
. ./test-functions

if ( ! truffle migrate --reset )
then
    exit 1;
fi

#truffle exec scripts/show-accounts.js
truffle exec scripts/change-ownership.js
truffle exec scripts/update-ether-price.js 1000

truffle exec scripts/add-to-whitelist.js 1
truffle exec scripts/start-crowdsale.js $(($(date +%s) + 300)) $(date +%s --date='next week') 10
truffle exec scripts/fastforward.js 3600
truffle exec scripts/send-eth.js $CROWDSALE 20000 1
FIRST=$(truffle exec scripts/balance-of.js 1 | tail -n 1)
truffle exec scripts/send-eth.js $CROWDSALE 2000 1
SECOND=$(truffle exec scripts/balance-of.js 1 | tail -n 1)

if ((($FIRST==40000000)) && (($SECOND==42000000)))
then
    OK
else
    FAIL
fi
