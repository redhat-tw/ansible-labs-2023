#!/bin/bash

## Deploy httpd
ansible linux -m yum -a "name=httpd state=present"
ansible linux -m template -a "src=templates/index.html.j2 dest=/var/www/html/index.html"
ansible linux -m systemd -a "name=httpd enabled=yes state=started"
ansible linux -m firewalld -a "service=http permanent=yes state=enabled"
ansible linux -m command -a "firewall-cmd --reload"

## Remove httpd
ansible linux -m systemd -a "name=httpd enabled=yes state=stopped"
ansible linux -m yum -a 'name=httpd state=absent'
