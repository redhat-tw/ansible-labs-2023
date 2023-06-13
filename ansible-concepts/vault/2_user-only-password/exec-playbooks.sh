#!/bin/bash

## Without Vault
ansible-playbook -i inventory/hosts.ini create-linuxuser.yml
ansible-playbook -i inventory/hosts.ini remove-linuxuser.yml

## With Vault (Please complete it)
# cp ./vars/userlist-plaintext.yml ./vars/userlist-encrypt.yml