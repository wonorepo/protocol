#!/bin/sh

. ./config

if ( ! truffle migrate --reset )
then
    exit 1;
fi

truffle exec scripts/give-tokens.js 0 1000
truffle exec scripts/balance-of.js 0
truffle exec scripts/release.js
truffle exec scripts/transfer-tokens.js 1 100 0
truffle exec scripts/balance-of.js 0
truffle exec scripts/balance-of.js 1
