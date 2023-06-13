#!/bin/bash

## Without Vault
ansible linux -m debug -a "var=user_list" -e "@./vars/userlist-plaintext.yml"

## With Vault
cp ./vars/userlist-plaintext.yml ./vars/userlist-encrypt.yml
ansible-vault encrypt ./vars/userlist-encrypt.yml

ansible linux -m debug -a "var=user_list" -e "@./vars/userlist-encrypt.yml" --ask-vault-pass
ansible linux -m debug -a "var=user_list" -e "@./vars/userlist-encrypt.yml" --vault-password-file vault-secret.txt
