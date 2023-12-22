#!/bin/bash

# Step 1: Make scripts executable
chmod +x create-auth.py create-wallet.sh

# Step 2: Run create-auth.py
./create-auth.py

# Step 3: Start containers using Docker Compose
docker compose down && docker compose up -d

sleep 1

# Step 4: Run create-wallet.sh
./create-wallet.sh
