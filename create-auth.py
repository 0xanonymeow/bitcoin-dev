#!/usr/bin/env python3
# Copyright (c) 2015-2021 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

# Usage: ./create-ath.py your_username your_password

from argparse import ArgumentParser
from getpass import getpass
from secrets import token_hex, token_urlsafe
from configparser import ConfigParser
import hmac
import base64
import fileinput
import sys
import re
import os

def read_env(file_path=".env"):
    with open(file_path) as f:
        file_content = '[section]\n' + f.read()

    config_parser = ConfigParser()
    config_parser.optionxform = str
    config_parser.read_string(file_content)

    for key, value in config_parser.items('section'):
        os.environ[key] = value

def write_env(file_path=".env", env_dict=None):
    # join the key-value pairs in the dictionary with '=' and separate them with '\n'
    text = '\n'.join([f"{key}={value}" for key, value in env_dict.items()])

    with open(file_path, 'w') as config_file:
        config_file.write(text)

def generate_salt(size):
    """create size byte hex salt"""
    return token_hex(size)

def generate_password():
    """create 32 byte b64 password"""
    return token_urlsafe(32)

def password_to_hmac(salt, password):
    m = hmac.new(salt.encode('utf-8'), password.encode('utf-8'), 'SHA256')
    return m.hexdigest()

def update_bitcoin_core_conf_file():
    username = os.getenv("RPC_USER")
    password = os.getenv("RPC_PASSWORD")
    chain = os.getenv("CHAIN")
    file_path = f'bitcoin-core/bitcoin-{chain}.conf'

    with open(file_path, 'r') as file:
        conf_content = file.read()

    rpc_auth_pattern = r'rpcauth=.*'

    salt = generate_salt(16)
    password_hmac = password_to_hmac(salt, password)

    conf_content = re.sub(rpc_auth_pattern, f'rpcauth={username}:{salt}${password_hmac}', conf_content)

    with open(file_path, 'w') as file:
        file.write(conf_content)

def update_bfgminer_conf_file():
    username = os.getenv("RPC_USER")
    password = os.getenv("RPC_PASSWORD")
    port = os.getenv("RPC_PORT")
    file_path = f'bfgminer/bfgminer.conf'

    with open(file_path, 'r') as file:
        conf_content = file.read()

    url_pattern = r'"url":\s*".*",'
    user_pattern = r'"user":\s*".*",'
    pass_pattern = r'"pass":\s*".*"'

    # Perform substitutions
    conf_content = re.sub(url_pattern, f'"url": "http://bitcoin-core:{port}",', conf_content)
    conf_content = re.sub(user_pattern, f'"user": "{username}",', conf_content)
    conf_content = re.sub(pass_pattern, f'"pass": "{password}"', conf_content)

    with open(file_path, 'w') as file:
        file.write(conf_content)

def update_config_file():
    username = os.getenv("RPC_USER")
    password = os.getenv("RPC_PASSWORD")
    port = os.getenv("RPC_PORT")
    file_path = 'bitcoin-node-manager/src/Config.php'

    with open(file_path, 'r') as file:
        config_content = file.read()

    user_pattern = r'const\s+RPC_USER\s*=\s*".*";'
    password_pattern = r'const\s+RPC_PASSWORD\s*=\s*".*";'
    port_pattern = r'const\s+RPC_PORT\s*=\s*".*";'

    config_content = re.sub(user_pattern, f'const RPC_USER = "{username}";', config_content)
    config_content = re.sub(password_pattern, f'const RPC_PASSWORD = "{password}";', config_content)
    config_content = re.sub(port_pattern, f'const RPC_PORT = "{port}";', config_content)

    with open(file_path, 'w') as file:
        file.write(config_content)

def main():
    read_env()

    parser = ArgumentParser(description='create login credentials for a JSON-RPC user')
    parser.add_argument('username', help='the username for authentication', nargs='?', default='default')
    parser.add_argument('password', help='leave empty to generate a random password or specify "-" to prompt for password', nargs='?')
    args = parser.parse_args()

    if not args.password:
        args.password = generate_password()
    elif args.password == '-':
        args.password = getpass()

    chain = os.getenv("CHAIN")
    port = 0

    if chain == "main":
        port = 8332
    elif chain == "test":
        port = 18333
    elif chain == "regtest":
        port = 18443

    env_data = {
        "CHAIN": chain,
        "RPC_PORT": port,
        "RPC_USER": args.username,
        "RPC_PASSWORD": args.password,
    }

    for key, value in env_data.items():
        os.environ[key] = str(value)

    write_env(env_dict=env_data)

    update_bitcoin_core_conf_file()
    print(f'bitcoin.conf updated with new rpcauth for user "{args.username}"')

    update_config_file()
    print(f'Config.php updated with new RPC_USER and RPC_PASSWORD for user "{args.username}"')

    update_bfgminer_conf_file()
    print(f'bfgminer.conf updated with new pool for "http://bitcoin-core:{port}"')

if __name__ == '__main__':
    main()