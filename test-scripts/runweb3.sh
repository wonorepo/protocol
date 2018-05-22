#!/bin/bash

SCRIPT="web3/$1.js"

if [ -z "$1" -o ! -f "$SCRIPT" ]
then
    echo "No such script" > /dev/stderr
    exit 1
fi

truffle console < "$SCRIPT"
