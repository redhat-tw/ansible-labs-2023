###### tags: `Red Hat` `public`
# Ansible Playbook 設計與開發 Labs
本文件紀錄本課程操作的 Labs 說明，分別為:

* `Lab 1`: Deploy LAMP Stack
* `Lab 2`: Use Community.Mysql Collection
* `Lab 3`: Use Ansible-lint


## Lab 1: Deploy LAMP Stack
此 Lab 將開發一套 Linux + Apache server + MySQL + PHP 的 Playbooks，並透過該 Playbook 來部署至測試機器上。在過程中修改專案的 Playbooks、Roles 與 Inventory 來了解如何實作。

1. 在 Ansible Control Node 透過 Git 下載 playbook 專案

```shell=
$ git clone https://github.com/redhat-tw/ansible-labs-2023
$ cd ansible-labs-2023/ansible-playbooks
```

2. 更改`inventory/hosts.ini` 機器清單

```shell=
$ vim inventory/hosts.ini

# 將以下改成自己 Managed Node IP:
[web]
192.249.100.100 ansible_user=root

[db]
192.249.100.100 ansible_user=root
```

修改後，透過 ansible ad-hoc 檢查:

```shell=
$ ansible -i inventory/hosts.ini -m ping all
192.249.100.100 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

> 若連線不通，請建立 SSH Key 登入，先到 Ansible 節點下以下指令:
> ```shell=
> # 取得 public key 內容，並複製起來
> $ cat .ssh/id_rsa.pub
> ```
> 
> 將上面拿到內容貼到 managed node 的 `.ssh/authorized_keys`


3. 透過 ansible-playbook 執行看看:

```shell=
$ ansible-playbook -v -i inventory/hosts.ini lamp.yml
```
> P.S. 這邊會出錯，屬於正常

4. 這邊出錯是因為沒有設定`mysql_root_password`，因此需要編輯 `inventory/group_vars/db.yml` 檔案內容:

```shell=
$ vim inventory/group_vars/db.yml

# 反註解，並修改以下內容
mysql_root_password: "Pass4mysql!!!31"
```

完成後，再透過 ansible-playbook 執行一次:

```shell=
# no_log 盡可能不要關掉，因為會在 output 會洩漏機密資訊的疑慮
$ ansible-playbook -v -i inventory/hosts.ini lamp.yml -e no_log=false

# 只針對 db play 做驗證
$ ansible-playbook -v -i inventory/hosts.ini lamp.yml --tags mysql
```

5. 這時我們就正常部署一套 LAMP 在 RHLE 上，然後可以透過以下指令來驗證功能:

```shell=
# 請修改成自己 IP
$ curl 192.249.100.100
$ curl 192.249.100.100/info.php

# 這個會發現 DB 連線異常
$ curl 192.249.100.100/employee.php
Connection failed: Access denied for user ''@'localhost' (using password: NO)
```
> 如果打不通的話，進到 Managed Node 執行以下指令，因為 ansible firewalld 預設不會 reload:
> ```shell=
> $ firewall-cmd --reload
> ```

6. 透過單獨執行 php role 來檢查狀況:

```shell=
$ ansible-playbook -v -i inventory/hosts.ini lamp.yml --tags php

# 進入到 managed node 檢查 php page 設定，php_database 變數資訊都沒帶進來
$ cat /var/www/html/employee.php
```

7. 這時編輯 `inventory/group_vars/web.yml` 將 `php_database` 變數設定完成:

```shell=
$ vim inventory/group_vars/web.yml

# 反註解，並修改以下內容
php_database:
  host: localhost
  username: root
  password: "Pass4mysql!!!31"
  name: test
```

然後再執行一次:

```shell=
$ ansible-playbook -v -i inventory/hosts.ini lamp.yml --tags php

# 在進入到 managed node 檢查 php page 設定，就會看到 php_database 變數資訊正確
$ cat /var/www/html/employee.php
```

8. 更改 httpd listen port，可以編輯`inventory/group_vars/web.yml`:

```shell=
$ vim inventory/group_vars/web.yml

# 在最下方加入以下內容
apache_default_content: "Welcome to <your message> site!"
apache_listen_port: 8080
```

並在執行一次 apache role，這邊會發生錯誤，因為 Smoke test 在 httpd 還沒 reload 之前就觸發，但`apache_listen_port` 變數已被改變，所以打不通:
```shell=
$ ansible-playbook -v -i inventory/hosts.ini lamp.yml --tags apache
```

9. 因此我們需要改變 `roles/httpd/tasks/main.yml` 檔案的兩個 task:

```yaml=
- name: Modify listent port
  become: yes
  lineinfile:
    dest:  "{{ apache_conf_dir }}/conf/httpd.conf"
    regexp: "^Listen [0-9]*"
    line: "Listen {{ apache_listen_port }}"
    state: present
    backrefs: yes
  notify: # 修改此行內容
  - Reload apache server
  - Test if Apache is installed and running
  tags: apache_config
  
# 在 roles/httpd/tasks/main.yml 中移除此 task
#- name: Test if Apache is installed and running
#  uri:
#   url: "http://localhost:{{ apache_listen_port }}"    
#  changed_when: False
```

接著編輯`roles/httpd/handlers/main.yml`，新增以下內容到最下面:

```yaml=
- name: Test if Apache is installed and running
  uri:
   url: "http://localhost:{{ apache_listen_port }}"    
  changed_when: False
```
並在執行一次 apache role 就可以正確改變 listen port:

```shell=
$ ansible-playbook -v -i inventory/hosts.ini lamp.yml --tags apache
```

## Lab 2: Use Community.Mysql Collection
此 Lab 將透過 Ansible 社區的 Collection 來執行 MySQL 操作。

1. 透過 curl 檢查以下，發現 MySQL 可以連到，但 DB 找不到:

```shell=
$ curl 192.249.100.100/employee.php
Connection failed: Unknown database 'test'
```

2. 修改`inventory/group_vars/db.yml` 內容:

```shell=
$ vim inventory/group_vars/db.yml

# 反註解，並修改以下內容
mysql_db_name: test

insert_data_list:
- id: 123
  name: KyleBai
```

3. 並透過 ansible-playbook 執行 `tests/test-db.yml` 來建立 DB 與 Table。會發現找不到 `community.mysql.mysql_db` 模組，這時要透過  ansible-galaxy 安裝才能正確執行

```shell=
$ ansible-playbook -v -i inventory/hosts.ini tests/test-db.yml
ERROR! couldn't resolve module/action 'community.mysql.mysql_db'. This often indicates a misspelling, missing collection, or incorrect module path.

# 安裝 community.mysql collection
$ ansible-galaxy collection install community.mysql

# 安裝完成後，再次執行一次
$ ansible-playbook -v -i inventory/hosts.ini tests/test-db.yml
```

4. 最後再 cURL 就會有資料進來:

```shell=
$ curl 192.249.100.100/employee.php
```

## Lab 3: Use Ansible-lint
此 Lab 將透過 Ansible-lint 來檢查 Playbooks，以幫助完善程式碼規範與開發最佳實踐。

```shell=
$ ansible-lint lamp.yml

INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:roles
INFO     Discovered files to lint using: git ls-files --cached --others --exclude-standard -z
INFO     Excluded removed files using: git ls-files --deleted -z
INFO     Discovered files to lint using: git ls-files --cached --others --exclude-standard -z
INFO     Excluded removed files using: git ls-files --deleted -z
[WARNING]: While constructing a mapping from <unicode string>, line 12, column 3, found a duplicate dict key (hosts). Using
last defined value only.
[WARNING]: While constructing a mapping from <unicode string>, line 12, column 3, found a duplicate dict key (roles). Using
last defined value only.
WARNING  Listing 3 violation(s) that are fatal
roles/httpd/tasks/main.yml:3: package-latest Package installs should not use latest
roles/mysql/tasks/main.yml:3: package-latest Package installs should not use latest
roles/php/tasks/main.yml:3: package-latest Package installs should not use latest
You can skip specific rules or tags by adding them to your configuration file:
# .ansible-lint
warn_list:  # or 'skip_list' to silence them completely
  - package-latest  # Package installs should not use latest

Finished with 3 failure(s), 0 warning(s) on 31 files.
```