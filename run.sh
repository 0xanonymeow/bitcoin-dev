#!/bin/bash

# step 1: rake scripts executable
chmod +x create-auth.py create-wallet.sh
# step 2: run create-auth.py
./create-auth.py
# step 3: start containers using Docker Compose
docker compose down && docker compose up bitcoin-core bitcoin-node-manager -d
sleep 1
# step 4: run create-wallet.sh
./create-wallet.sh
source .env
# step 5: generate some blocks
./cmd.sh generatetoaddress 250 $WALLET_ADDRESS
# step 6: run bfgminer
docker compose up bfgminer --build -d