#!/bin/bash

## Without Vault
ansible-playbook -i inventory/hosts.ini create-linuxuser.yml
ansible-playbook -i inventory/hosts.ini remove-linuxuser.yml

## With Vault
ansible-vault encrypt_string 'P@ssw0rd' --name password
ansible-vault encrypt_string '123456' --name password 
ansible-vault encrypt_string '45678' --name password
cp ./vars/userlist-plaintext.yml ./vars/userlist-encrypt.yml
vim ./vars/userlist-encrypt.yml

ansible-playbook -i inventory/hosts.ini create-linuxuser-encrypt.yml --ask-vault-pass
ansible-playbook -i inventory/hosts.ini remove-linuxuser-encrypt.yml --vault-password-file vault-secret.txt