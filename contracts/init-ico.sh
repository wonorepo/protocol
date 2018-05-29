#!/bin/sh

if ( ! truffle migrate --reset )
then
    exit 1
fi

truffle exec scripts/show-accounts.js
truffle exec scripts/change-ownership-of-token.js
truffle exec scripts/update-ether-price.js 700

truffle exec scripts/add-to-whitelist.js 1
truffle exec scripts/send-eth.js 0xaf9e40360c6e52f0736e30942e2258ce2b0b9d3f 10 1
truffle exec scripts/balance-of.js 1

