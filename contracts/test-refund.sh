#!/bin/bash

. ./config
. ./test-functions

truffle migrate --reset
STEP_CHECK Migration

truffle exec scripts/change-ownership.js
truffle exec scripts/update-ether-price.js 1000
truffle exec scripts/add-to-whitelist.js 1
truffle exec scripts/add-to-whitelist.js 2 
truffle exec scripts/start-crowdsale.js $(($(date +%s) + 300)) $(date +%s --date='next week') 10
truffle exec scripts/set-token-distribution-address.js $TOKENDISTRIBUTOR
truffle exec scripts/set-ether-distribution-address.js $ETHERDISTRIBUTOR
truffle exec scripts/fastforward.js 3600
truffle exec scripts/send-eth.js $CROWDSALE 1000   1
truffle exec scripts/send-eth.js $CROWDSALE 100    2

# Check for right balance
COLLECTED=$(truffle exec scripts/get-balance.js $CROWDSALE | tail -n 1)
echo $COLLECTED
(( $COLLECTED == 1100 ))
STEP_CHECK ICO

BALANCE[1]=$(truffle exec scripts/get-balance.js 1 | tail -n 1)
BALANCE[2]=$(truffle exec scripts/get-balance.js 2 | tail -n 1)
echo ${BALANCE[1]} ${BALANCE[2]}
( [[ "${BALANCE[1]}" == "999998999.999999999999773532" ]] && [[ "${BALANCE[2]}" == "999999899.99999999999983481" ]] )
STEP_CHECK Funding  

#truffle exec scripts/fastforward.js $((86400 * 10))
truffle exec scripts/stop-crowdsale.js

truffle exec scripts/crowdsale-refund.js 1
BALANCE[1]=$(truffle exec scripts/get-balance.js 1 | tail -n 1)
BALANCE[2]=$(truffle exec scripts/get-balance.js 2 | tail -n 1)
echo ${BALANCE[1]} ${BALANCE[2]}
( [[ "${BALANCE[1]}" == "999999999.999980017999773532" ]] && [[ "${BALANCE[2]}" == "999999899.99999999999983481" ]] )
STEP_CHECK Refunding

RESULT
