#!/bin/bash

if [ -f .env ]; then
    source .env
else
    echo "error: .env file not found."
fi

CONTAINER_NAME=bitcoin-core
AUTH_ARGS="-chain=${CHAIN} -rpcuser=${RPC_USER} -rpcpassword=${RPC_PASSWORD} -rpcport=${RPC_PORT}"

CMD=$1
# remove the first argument (CMD) from the list
shift 

if [ $# -gt 0 ]; then
    docker exec -it "${CONTAINER_NAME}" bash -c "bitcoin-cli ${AUTH_ARGS} ${CMD} $@"
else
    docker exec -it "${CONTAINER_NAME}" bash -c "bitcoin-cli ${AUTH_ARGS} ${CMD}"
fi