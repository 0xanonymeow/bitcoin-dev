#!/bin/bash

if [ -f .env ]; then
    source .env
else
    echo "error: .env file not found."
    exit 1
fi

# step 1: rake scripts executable
chmod +x create-auth.py create-wallet.sh
# step 2: run create-auth.py
if [ -z "${RPC_PASSWORD:-}" ]; then
    ./create-auth.py
fi

# step 3: start containers using Docker Compose
if [[ "$#" -gt 0 && "$@" =~ "-ui" ]]; then
    docker-compose down && docker-compose up bitcoin-core bitcoin-node-manager -d
else
    docker-compose down && docker-compose up bitcoin-core -d
fi

sleep 1
# step 4: run create-wallet.sh
./create-wallet.sh
source .env

# step 5: generate some blocks
if [ "$CHAIN" == "regtest" ]; then
    ./cmd.sh generatetoaddress 250 $WALLET_ADDRESS
    echo "regtest: 250 blocks generated."
fi 

# step 6: run bfgminer
if [[ "$#" -gt 0 && "$@" =~ "-b" ]]; then
    docker compose up bfgminer --build -d
else
    docker compose up bfgminer -d
fi