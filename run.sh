#!/bin/bash

# check if the .env file already exists
if [ ! -e  ".env" ]; then
    # copy the contents of the source file to the destination file
    cp ".env.example" ".env"
    echo ".env is created"
fi

if [[ "$#" -gt 0 && "$@" =~ "-n" ]]; then
        value="0"
    else
        value="1"
fi

for key in "DNSSEED" "FIXEDSEEDS"; do
    # check if the key already exists in the .env file
    if grep -q "^$key=" .env; then
        # update the existing key with the new value
        if sed --version 2>&1 | grep -q "GNU"; then
            sed -i 's/^'"$key"'=.*/'"$key=$value"'/' .env
        else
            sed -i "" 's/^'"$key"'=.*/'"$key=$value"'/' .env
        fi
    else
        # append the new key-value pair to the .env file
        echo "$key=$value" >> .env
    fi
done

echo "updated DNSSEED and FIXEDSEEDS in .env file."

# step 1: rake scripts executable
chmod +x create-auth.py create-wallet.sh
# step 2: run create-auth.py
if [[ "$#" -eq 0 || ! "$@" =~ "-k" ]]; then
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