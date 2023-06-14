#!/bin/bash
ansible-playbook -i inventory/hosts.ini main.yml -e "employ_name=Alice"