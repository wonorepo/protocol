#!/bin/bash

. ./config
. ./test-functions

if (false)
then
    false
fi

truffle migrate --reset
STEP_CHECK Migration

truffle exec scripts/change-ownership.js
truffle exec scripts/update-ether-price.js 203
truffle exec scripts/add-to-whitelist.js 1
truffle exec scripts/add-to-whitelist.js 2
#truffle exec scripts/add-to-whitelist.js 3
truffle exec scripts/start-crowdsale.js $(($(date +%s) + 300)) $(date +%s --date='next week') 10
#truffle exec scripts/set-token-distribution-address.js $TOKENDISTRIBUTOR
#truffle exec scripts/set-ether-distribution-address.js $ETHERDISTRIBUTOR
truffle exec scripts/fastforward.js 3600
echo -e "\e[1msend-eth 1.5\e[0m"
truffle exec scripts/send-eth.js $CROWDSALE 7.9 1
truffle exec scripts/fastforward.js $((86400 * 2))
echo -e "\e[1mregister-saft 2 2000\e[0m"
truffle exec scripts/register-saft.js 2 2000
echo -e "\e[1mget-total-collected\e[0m"
COLLECTED=$(truffle exec scripts/get-total-collected.js | tail -n 1)
echo $COLLECTED

echo -e "\e[1mregister-saft 2 $(bc -l <<< "(1000000 - $COLLECTED) / 203") \e[0m"
truffle exec scripts/register-saft.js 2 $(bc -l <<< "(1000000 - $COLLECTED) / 203")
echo -e "\e[1mupdate-ether-price 1000 \e[0m"
truffle exec scripts/update-ether-price.js 1000
echo -e "\e[1mregister-saft 2 1 \e[0m"
truffle exec scripts/register-saft.js 1 2

echo -e "\e[1msend-eth 1.5\e[0m"
truffle exec scripts/send-eth.js $CROWDSALE 0.25 1

echo -e "\e[1mget-total-collected\e[0m"
COLLECTED=$(truffle exec scripts/get-total-collected.js | tail -n 1)
echo $COLLECTED
