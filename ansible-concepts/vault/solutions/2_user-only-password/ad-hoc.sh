#!/bin/bash

## Without Vault
ansible linux -m debug -a "var=user_list" -e "@./vars/userlist-plaintext.yml"

## With Vault
ansible-vault encrypt_string 'P@ssw0rd' --name password
ansible-vault encrypt_string '123456' --name password 
ansible-vault encrypt_string '45678' --name password
cp ./vars/userlist-plaintext.yml ./vars/userlist-encrypt.yml
vim ./vars/userlist-encrypt.yml

ansible linux -m debug -a "var=user_list" -e "@./vars/userlist-encrypt.yml" --ask-vault-pass
ansible linux -m debug -a "var=user_list" -e "@./vars/userlist-encrypt.yml" --vault-password-file vault-secret.txt
