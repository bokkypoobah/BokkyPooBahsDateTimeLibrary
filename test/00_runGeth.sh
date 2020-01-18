#!/bin/sh

rm -f ./testchain/geth/chaindata/*

# geth --datadir ./testchain init genesis.json

# geth --datadir ./testchain --unlock 0 --password ./testpassword --rpc --rpccorsdomain '*' --rpcport 8646 --rpcapi "eth,net,web3,debug" --port 32323 --mine --minerthreads 1 --maxpeers 0 --targetgaslimit 994712388 console
geth --allow-insecure-unlock --dev --dev.period 1 --datadir ./testchain --rpc --rpccorsdomain '*' --rpcport 8646 --rpcapi "eth,net,web3,debug" --port 32323 --maxpeers 0 --targetgaslimit 994712388 console
