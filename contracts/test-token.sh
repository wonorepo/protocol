#!/bin/sh

. ./config
. ./test-functions

if ( ! truffle migrate --reset )
then
    exit 1;
fi

truffle exec scripts/give-tokens.js 0 1000
FIRST=$(truffle exec scripts/balance-of.js 0 | tail -n 1)
truffle exec scripts/release.js
truffle exec scripts/transfer-tokens.js 1 100 0
SECOND=$(truffle exec scripts/balance-of.js 0 | tail -n 1)
THIRD=$(truffle exec scripts/balance-of.js 1 | tail -n 1)

if (((FIRST==1000)) && ((SECOND==900)) && ((THIRD==100)))
then
    OK
else
    FAIL
fi
