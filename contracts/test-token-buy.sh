#!/bin/bash

. ./config
. ./test-functions

truffle migrate --reset
STEP_CHECK Migration

truffle exec scripts/change-ownership.js
truffle exec scripts/update-ether-price.js 1000
truffle exec scripts/add-to-whitelist.js 1
truffle exec scripts/add-to-whitelist.js 2 
truffle exec scripts/add-to-whitelist.js 3 
truffle exec scripts/start-crowdsale.js $(($(date +%s) + 300)) $(date +%s --date='next week') 10
truffle exec scripts/set-token-distribution-address.js $TOKENDISTRIBUTOR
truffle exec scripts/set-ether-distribution-address.js $ETHERDISTRIBUTOR
truffle exec scripts/fastforward.js 3600
echo -e "\e[32;1mselling\e[0m"
truffle exec scripts/send-eth.js $CROWDSALE 1000   1
truffle exec scripts/send-eth.js $CROWDSALE 100    2
truffle exec scripts/send-eth.js $CROWDSALE 0.0001 3
echo -e "\e[33;1mending\e[0m"
#truffle exec scripts/fastforward.js $((86400 * 10))
echo -e "\e[35;1mchecking\e[0m"

# Check for right balance
COLLECTED=$(truffle exec scripts/get-balance.js $CROWDSALE | tail -n 1)
SOLD[1]=$(truffle exec scripts/balance-of.js 1 | tail -n 1)
SOLD[2]=$(truffle exec scripts/balance-of.js 2 | tail -n 1)
SOLD[3]=$(truffle exec scripts/balance-of.js 3 | tail -n 1)
SOLD[4]=$(truffle exec scripts/balance-of.js $CROWDSALE | tail -n 1)

echo ${SOLD[1]} ${SOLD[2]} ${SOLD[3]} ${SOLD[4]}
(  [[ "${SOLD[1]}" == "2000000" ]] && [[ "${SOLD[2]}" == "200000"     ]] \
&& [[ "${SOLD[3]}" == "0.2"     ]] && [[ "${SOLD[4]}" == "1460000.06" ]] )
STEP_CHECK Sold

RESULT
