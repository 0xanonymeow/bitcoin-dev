#!/bin/bash

if [ -f .env ]; then
    source .env
else
    echo "error: .env file not found."
    exit 1
fi

CONTAINER_NAME=bitcoin-core
AUTH_ARGS="-chain=${CHAIN} -rpcuser=${RPC_USER} -rpcpassword=${RPC_PASSWORD} -rpcport=${RPC_PORT}"
WALLET_NAME=${RPC_USER}
# command to create a new wallet
CREATE_WALLET_CMD="bitcoin-cli ${AUTH_ARGS} createwallet ${WALLET_NAME}"
CREATE_WALLET_ADDRESS="bitcoin-cli ${AUTH_ARGS} -rpcwallet=${RPC_USER} getnewaddress -addresstype legacy"

# execute the commands inside the Docker container and save the output to a file
WALLET_INFO=$(docker exec ${CONTAINER_NAME} bash -c "${CREATE_WALLET_CMD}" 2>&1)

# check if there are any errors in the output
if [[ "$WALLET_INFO" == *"Error"* ]]; then
    echo "error: failed to create wallet."
    exit 1
fi

# execute the command to get a new address from the created wallet
WALLET_ADDRESS=$(docker exec ${CONTAINER_NAME} bash -c "${CREATE_WALLET_ADDRESS}" 2>&1)
echo $WALLET_ADDRESS
# check if there are any errors in the wallet address output
if [[ "$WALLET_ADDRESS" == *"Error"* ]]; then
    echo "error: failed to get wallet address."
    exit 1
else
    echo "" >> .env

    for key in "WALLET_NAME" "WALLET_ADDRESS"; do
        value="${!key}"
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
fi

echo "updated .env file with new variables."