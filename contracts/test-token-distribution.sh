#!/bin/sh

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
truffle exec scripts/start-crowdsale.js $(($(date +%s) + 300)) $(date +%s --date='next week') 10
truffle exec scripts/set-token-distribution-address.js $TOKENDISTRIBUTOR
truffle exec scripts/set-ether-distribution-address.js $ETHERDISTRIBUTOR
truffle exec scripts/fastforward.js 3600
truffle exec scripts/send-eth.js $CROWDSALE 21000 1
truffle exec scripts/fastforward.js $((86400 * 10))

ETHER=$(truffle exec scripts/get-balance.js $CROWDSALE | tail -n 1)
TOKEN=$(truffle exec scripts/balance-of.js $CROWDSALE | tail -n 1)

echo -e "\e[31;1m$ETHER \e[32m$TOKEN\e[0m"

truffle exec scripts/mine-block.js
truffle exec scripts/withdraw.js
truffle exec scripts/withdraw-tokens.js
truffle exec scripts/release-tokens.js

ETHDISTR=$(truffle exec scripts/get-balance.js $ETHERDISTRIBUTOR | tail -n 1)
TOKDISTR=$(truffle exec scripts/balance-of.js $TOKENDISTRIBUTOR | tail -n 1 | awk '{ print $1+0 }')

echo -e "\e[31;1m$ETHDISTR \e[32m$TOKDISTR\e[0m"

truffle exec scripts/token-distribute.js
for ((PURPOSE = 0; PURPOSE < 8; PURPOSE++))
do
    TOTAL[$PURPOSE]=$(truffle exec scripts/token-get-total.js $PURPOSE | tail -n 1)
    AVAIL[$PURPOSE]=$(truffle exec scripts/token-get-available.js $PURPOSE | tail -n 1)
    echo -e "\e[36;1m${TOTAL[$PURPOSE]} \e[32m${AVAIL[$PURPOSE]}\e[0m" 
done

for ((PURPOSE = 0; PURPOSE < 8; PURPOSE++))
do
    truffle exec scripts/token-set-address.js $PURPOSE $(($PURPOSE + 10))
done

for ((PURPOSE = 0; PURPOSE < 8; PURPOSE++))
do
    truffle exec scripts/token-withdraw.js $PURPOSE ${AVAIL[$PURPOSE]}
done

for ((PURPOSE = 0; PURPOSE < 8; PURPOSE++))
do
    BALANCE[$PURPOSE]=$(truffle exec scripts/balance-of.js $(($PURPOSE + 10)) | tail -n 1)
    echo ${BALANCE[$PURPOSE]}
done

# if ((($ETHDISTR==$ETHER)) && (($TOKEN==5500000)) && [ "$TOKDISTR" == "3.16667e+07" ])
# then
#     OK
# else
#     FAIL
# fi
