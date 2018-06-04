#!/bin/sh

. ./config

if ( ! truffle migrate --reset )
then
    exit 1;
fi

truffle exec scripts/show-accounts.js
truffle exec scripts/change-ownership.js
truffle exec scripts/update-ether-price.js 1000

truffle exec scripts/add-to-whitelist.js 1
truffle exec scripts/send-eth.js $CROWDSALE 2000 1
truffle exec scripts/balance-of.js 1
truffle exec scripts/balance-of.js $CROWDSALE
