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
truffle exec scripts/update-ether-price.js 1000
truffle exec scripts/add-to-whitelist.js 1
truffle exec scripts/add-to-whitelist.js 9
truffle exec scripts/start-crowdsale.js $(($(date +%s) + 300)) $(date +%s --date='next week') 10
truffle exec scripts/set-token-distribution-address.js $TOKENDISTRIBUTOR
truffle exec scripts/set-ether-distribution-address.js $ETHERDISTRIBUTOR
truffle exec scripts/fastforward.js 3600
echo "REG SAFT"
truffle exec scripts/send-eth.js $CROWDSALE 8.5 1
truffle exec scripts/register-saft.js 9 891.499
truffle exec scripts/register-saft.js 9 100.001
truffle exec scripts/send-eth.js $CROWDSALE 12000 1
truffle exec scripts/fastforward.js $((86400 * 10))

# Check for right balance
COLLECTED=$(truffle exec scripts/get-balance.js $CROWDSALE | tail -n 1)
SOLD=$(truffle exec scripts/balance-of.js 1 | tail -n 1)
BONUS=$(truffle exec scripts/balance-of.js $CROWDSALE | tail -n 1)
SAFT=$(truffle exec scripts/get-saft-eth.js | tail -n 1)
echo $COLLECTED $SOLD $BONUS $SAFT
( (($COLLECTED == 12000)) && (($SOLD == 24000000)) && (($BONUS == 5500000)) && (($SAFT == 1000)) )
STEP_CHECK "ICO"

# Check ICO funds withdrawal
truffle exec scripts/mine-block.js
truffle exec scripts/withdraw.js
truffle exec scripts/withdraw-tokens.js
truffle exec scripts/release-tokens.js
ETHDISTR=$(truffle exec scripts/get-balance.js $ETHERDISTRIBUTOR | tail -n 1)
TOKDISTR=$(truffle exec scripts/balance-of.js $TOKENDISTRIBUTOR | tail -n 1 | awk '{ print $1+0 }')
echo $ETHDISTR $TOKDISTR
( (($ETHDISTR == 12000)) && [[ "$TOKDISTR" == "1.48235e+07" ]] )
STEP_CHECK "Widthdraw funds for distribution"

# Distributing ether
truffle exec scripts/ether-distribute.js
for ((PURPOSE = 0; PURPOSE < 6; PURPOSE++))
do
    ETHTOTAL[$PURPOSE]=$(truffle exec scripts/ether-get-total.js $PURPOSE | tail -n 1)
    ETHAVAIL[$PURPOSE]=$(truffle exec scripts/ether-get-available.js $PURPOSE | tail -n 1)
    echo ${ETHTOTAL[$PURPOSE]} ${ETHAVAIL[$PURPOSE]} 
done
(  ((${ETHTOTAL[0]} == 5520)) && ((${ETHAVAIL[0]} == 1920)) \
&& ((${ETHTOTAL[1]} == 2640)) && [[ "${ETHAVAIL[1]}" == "553.08" ]] \
&& ((${ETHTOTAL[2]} == 1200)) && ((${ETHAVAIL[2]} == 480)) \
&& ((${ETHTOTAL[3]} == 1560)) && ((${ETHAVAIL[3]} == 780)) \
&& ((${ETHTOTAL[4]} == 600))  && ((${ETHAVAIL[4]} == 240)) \
&& ((${ETHTOTAL[5]} == 480))  && ((${ETHAVAIL[5]} == 480)) )
STEP_CHECK "Ether distribution (period 0)"

# Distributing tokens
truffle exec scripts/token-distribute.js
for ((PURPOSE = 0; PURPOSE < 8; PURPOSE++))
do
    TOKTOTAL[$PURPOSE]=$(truffle exec scripts/token-get-total.js $PURPOSE | tail -n 1)
    TOKAVAIL[$PURPOSE]=$(truffle exec scripts/token-get-available.js $PURPOSE | tail -n 1)
    echo ${TOKTOTAL[$PURPOSE]} ${TOKAVAIL[$PURPOSE]} 
done
(  ((${TOKTOTAL[0]} == 2520000)) && ((${TOKAVAIL[0]} == 378000 )) \
&& ((${TOKTOTAL[1]} == 630000 )) && ((${TOKAVAIL[1]} == 630000 )) \
&& ((${TOKTOTAL[2]} == 1260000)) && ((${TOKAVAIL[2]} == 189000 )) \
&& ((${TOKTOTAL[3]} == 976500 )) && ((${TOKAVAIL[3]} == 157500 )) \
&& ((${TOKTOTAL[4]} == 976500 )) && ((${TOKAVAIL[4]} == 157500 )) \
&& ((${TOKTOTAL[5]} == 1575000)) && ((${TOKAVAIL[5]} == 1575000)) \
&& ((${TOKTOTAL[6]} == 945000 )) && ((${TOKAVAIL[6]} == 945000 )) \
&& ((${TOKTOTAL[7]} == 1260000)) && ((${TOKAVAIL[7]} == 1260000)) )
STEP_CHECK "Token distribution (period 0)"

# PoC delivery
truffle exec scripts/token-poc-deliver.js
# F.FWD 13 months to get in period 1 for tokens and ether
truffle exec scripts/fastforward.js $(($(date +%s --date='13 months') - $(date +%s)))

# Ether period 1
ETHAVAIL[0]=$(truffle exec scripts/ether-get-available.js 0 | tail -n 1)
echo ${ETHTOTAL[0]} ${ETHAVAIL[0]}
((${ETHAVAIL[0]} == 4620))
STEP_CHECK "Ether distribution (period 1)" 

# Tokens period 1
TOKAVAIL[0]=$(truffle exec scripts/token-get-available.js 0 | tail -n 1)
echo ${TOKTOTAL[0]} ${TOKAVAIL[0]}
((${TOKAVAIL[0]} == 1008000))
STEP_CHECK "Token distribution (period 1)" 

# F.FWD 6 months to get in period 2 for tokens
truffle exec scripts/fastforward.js $(($(date +%s --date='6 months') - $(date +%s)))

# Tokens period 2
TOKAVAIL[0]=$(truffle exec scripts/token-get-available.js 0 | tail -n 1)
echo ${TOKTOTAL[0]} ${TOKAVAIL[0]}
((${TOKAVAIL[0]} == 1512000))
STEP_CHECK "Token distribution (period 2)" 

# F.FWD 6 months to get in period 2 for tokens
truffle exec scripts/fastforward.js $(($(date +%s --date='6 months') - $(date +%s)))

# Ether period 2
ETHAVAIL[0]=$(truffle exec scripts/ether-get-available.js 0 | tail -n 1)
echo ${ETHTOTAL[0]} ${ETHAVAIL[0]}
((${ETHAVAIL[0]} == 5520))
STEP_CHECK "Ether distribution (period 2)" 

# Tokens period 3
TOKAVAIL[0]=$(truffle exec scripts/token-get-available.js 0 | tail -n 1)
echo ${TOKTOTAL[0]} ${TOKAVAIL[0]}
((${TOKAVAIL[0]} == 2016000))
STEP_CHECK "Token distribution (period 3)" 

# F.FWD 6 months to get in period 2 for tokens
truffle exec scripts/fastforward.js $(($(date +%s --date='6 months') - $(date +%s)))

# Tokens period 4
TOKAVAIL[0]=$(truffle exec scripts/token-get-available.js 0 | tail -n 1)
echo ${TOKTOTAL[0]} ${TOKAVAIL[0]}
((${TOKAVAIL[0]} == 2520000))
STEP_CHECK "Token distribution (period 4)" 

RESULT
