#!/bin/bash

## Without Vault
ansible-playbook -i inventory/hosts.ini create-linuxuser.yml
ansible-playbook -i inventory/hosts.ini remove-linuxuser.yml

## With Vault
cp ./vars/userlist-plaintext.yml ./vars/userlist-encrypt.yml
ansible-vault encrypt ./vars/userlist-encrypt.yml

ansible-playbook -i inventory/hosts.ini create-linuxuser-encrypt.yml --ask-vault-pass
ansible-playbook -i inventory/hosts.ini remove-linuxuser-encrypt.yml --vault-password-file vault-secret.txt