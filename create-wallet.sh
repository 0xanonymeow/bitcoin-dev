#!/bin/bash

if [ -f .env ]; then
    source .env
else
    echo "error: .env file not found."
fi

CONTAINER_NAME=bitcoin-core
AUTH_ARGS="-chain=${CHAIN} -rpcuser=${RPC_USER} -rpcpassword=${RPC_PASSWORD} -rpcport=${RPC_PORT}"

# command to create a new wallet
CREATE_WALLET_CMD="bitcoin-cli ${AUTH_ARGS} createwallet default"
CREATE_WALLET_ADDRESS="bitcoin-cli ${AUTH_ARGS} -rpcwallet=default getnewaddress"

# execute the commands inside the Docker container and save the output to a file
WALLET_INFO=$(docker exec -it ${CONTAINER_NAME} bash -c "${CREATE_WALLET_CMD}")

# check if there are any errors in the output
if [[ "$WALLET_INFO" == *"Error"* ]]; then
    echo "error: failed to create wallet."
else
    # execute the command to get a new address from the created wallet
    WALLET_ADDRESS=$(docker exec -it ${CONTAINER_NAME} bash -c "${CREATE_WALLET_ADDRESS}" 2>&1)

    # check if there are any errors in the wallet address output
    if [[ "$WALLET_ADDRESS" == *"Error"* ]]; then
        echo "error: failed to get wallet address."
    else
        WALLET_NAME=default
        
        echo "" >> .env

        for key in "WALLET_NAME" "WALLET_ADDRESS"; do
            value="${!key}"
            # check if the key already exists in the .env file
            if grep -q "^$key=" .env; then
                # update the existing key with the new value
                sed -i "s/^$key=.*/$key=$value/" .env
            else
                # append the new key-value pair to the .env file
                echo "$key=$value" >> .env
            fi
        done
    fi
fi



echo "updated .env file with new variables."