# bitcoin dev

## Steps to run the project

1. Duplicate the `.env.example` file and name it `.env` then update the `CHAIN` variable to your desired value. Example: `CHAIN=main`
2. Run `chmod +x create-auth.py create-wallet.sh` to make the scripts executable.
3. Run the `./create-auth.py your_username your_password` command to create authentication.
4. Run `docker compose up -d` to start the necessary containers.
5. Run the `./create-wallet.sh` command to create a wallet.

### Optional: Initialize with Default Values

If you want to initialize everything with default values, you can run the `run.sh` script. This script will handle authentication, container setup, and wallet creation with default values:

```bash
chmod +x run.sh
./run.sh
```

Please make sure you have all the necessary dependencies installed before running these commands.
