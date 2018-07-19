#!/bin/sh

. ./config

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
truffle exec scripts/send-eth.js $CROWDSALE 21000 1
truffle exec scripts/balance-of.js 1
truffle exec scripts/balance-of.js $CROWDSALE
