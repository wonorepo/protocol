#!/bin/bash

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
truffle exec scripts/add-to-whitelist.js 2
truffle exec scripts/start-crowdsale.js $(($(date +%s) + 300)) $(date +%s --date='next week') 10
truffle exec scripts/fastforward.js 3600
truffle exec scripts/send-eth.js $CROWDSALE  1000 1
truffle exec scripts/send-eth.js $CROWDSALE 20000 2
truffle exec scripts/fastforward.js $((86400 * 10))
truffle exec scripts/release-tokens.js

FIRST=$(truffle exec scripts/balance-of.js 1 | tail -n 1)
SECOND=$(truffle exec scripts/balance-of.js 2 | tail -n 1)
THIRD=$(truffle exec scripts/balance-of.js $CROWDSALE | tail -n 1)

((($FIRST==2000000)) && (($SECOND==40000000)) && (($THIRD==5500000)))
STEP_CHECK "Giving tokens"

BONUS[1]=$(truffle exec scripts/crowdsale-getbonus.js 1 | tail -n 1)
BONUS[2]=$(truffle exec scripts/crowdsale-getbonus.js 2 | tail -n 1)

echo ${BONUS[1]} ${BONUS[2]}
(((${BONUS[1]}==1400000)) && ((${BONUS[2]}==4100000)))
STEP_CHECK "getBonus()"

BOUGHT[1]=$(truffle exec scripts/crowdsale-getbought.js 1 | tail -n 1)
BOUGHT[2]=$(truffle exec scripts/crowdsale-getbought.js 2 | tail -n 1)

echo ${BOUGHT[1]} ${BOUGHT[2]}
(((${BOUGHT[1]}==2000000)) && ((${BOUGHT[2]}==40000000)))
STEP_CHECK "getBought()"

AVAILABLE[1]=$(truffle exec scripts/crowdsale-getbonusavailable.js 1 | tail -n 1)
AVAILABLE[2]=$(truffle exec scripts/crowdsale-getbonusavailable.js 2 | tail -n 1)
truffle exec scripts/fastforward.js $((86400 * 60))
AVAILABLE[3]=$(truffle exec scripts/crowdsale-getbonusavailable.js 1 | tail -n 1)
truffle exec scripts/fastforward.js $((86400 * 60))
AVAILABLE[4]=$(truffle exec scripts/crowdsale-getbonusavailable.js 1 | tail -n 1)

echo ${AVAILABLE[1]} ${AVAILABLE[2]} ${AVAILABLE[3]} ${AVAILABLE[4]}

(  (( ${AVAILABLE[1]} == 300000 )) && (( ${AVAILABLE[2]} == 4100000 )) \
&& (( ${AVAILABLE[3]} == 600000 )) && (( ${AVAILABLE[4]} == 900000  )) )
STEP_CHECK "getBonusAvailable()"

truffle exec scripts/crowdsale-claimbonus.js 1 100000
CLAIMED=$(truffle exec scripts/crowdsale-getbonusclaimed.js 1 | tail -n 1)
AVAILABLE[5]=$(truffle exec scripts/crowdsale-getbonusavailable.js 1 | tail -n 1)
echo $CLAIMED ${AVAILABLE[5]}

( (($CLAIMED == 100000)) && ((${AVAILABLE[5]} == 800000)) )
STEP_CHECK "getBonusClaimed()"

RESULT
