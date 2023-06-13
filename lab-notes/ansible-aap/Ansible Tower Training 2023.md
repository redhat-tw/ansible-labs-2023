# Ansible Tower Training 2023
###### tags: `public` `Red Hat`
[toc]

<div style="page-break-after: always;"></div>

## 環境介紹
* ansible-execution-node: Ansible 節點 (Control Node)
* student 主機: 管理節點 (Managed Node)

Ansible Tower: https://awx.lab.k2rb.com

Ansible Tower Resources
| username | Organization | Role   |
| -------- | -------- | -------- |
| `student1` | student1 | Organization Admin |
| `student2` | student2 | Organization Admin |
| `student3` | student3 | Organization Admin |
| `student4` | student4 | Organization Admin |
| `student5` | student5 | Organization Admin |
| `student6` | student6 | Organization Admin |
| `student7` | student7 | Organization Admin |
| `student8` | student8 | Organization Admin |
| `student9` | student9 | Organization Admin |
| `student10` | student10| Organization Admin |
| `student11` | student11| Organization Admin |
| `student12` | student12| Organization Admin |
| `student13` | student13| Organization Admin |
| `student14` | student14| Organization Admin |
| `student15` | student15| Organization Admin |


## 查看環境
1. 登入 Ansible Tower
2. 選擇 `ACCESS > Organizations` 查看 Organization。每一位學生皆有自己的 Organization。 (Organization Admin)
![](https://hackmd.io/_uploads/SyogTeUBh.png)
3. 登入 Jump Server，透過 Web Terminal 存取到 ansible-execution-node
4. Clone 下來 Tower 使用到的 Lab
```bash=
## Demo Playbooks
git clone https://github.com/ansible/ansible-tower-samples.git

## LAMP (Apache + Mysql + PHP) 範例
git clone https://github.com/redhat-tw/ansible-labs-2023.git
```

<div style="page-break-after: always;"></div>

## 建立 Inventory
**實作目標：建立 Ansible Tower Inventory。**

1. 登入 Jump Server，透過 Web Terminal 存取對應的 student 主機，並查看 IP 資訊
```shell=
ip -4 address
```

2. 登入 Jump Server，透過 Web Terminal 存取到 ansible-execution-node，並進入 Lab 目錄。
```bash=
cd ansible-labs-2023/ansible-aap
```
3. 修改 Inventory，將 IP 改成步驟 1 查詢到的 student 主機的 IP。 
```bash=
vim inventory/hosts.ini
```
```yaml=
[web]
192.168.1.12 ansible_user=root app_name='["apache", "mariadb"]'

[db]
192.168.1.12 ansible_user=root app_name='["apache", "mariadb"]'
```
4. 點選左側 `Ansible Tower Dashboard > RESOURCES > Inventories`，點擊右上角 + ，建立新的 Inventory。
![](https://hackmd.io/_uploads/SJBgCgISn.png)

5. 輸入 Inventory 資訊，Organization 選擇自己的組織，接著點選 SAVE。
![](https://hackmd.io/_uploads/HyL66l8S2.png)


6. 點選 Hosts，接著點選 +，新增管理主機。
![](https://hackmd.io/_uploads/SJavMbIS2.png)

    根據步驟 3 的資訊，輸入 student 主機 IP 以及 extra variables，接著點擊 SAVE，存檔。
    ![](https://hackmd.io/_uploads/r1TtGWUr3.png)

    ![](https://hackmd.io/_uploads/BkgiG-8rh.png)


7. 點選 Groups，接著點選 +，新增管理群組。
![](https://hackmd.io/_uploads/S1TDXZ8Bn.png)

    建立一個 web 以及 db 群組。
    ![](https://hackmd.io/_uploads/S1rlEW8S2.png)
    
    ![](https://hackmd.io/_uploads/rkyM4-LB2.png)
    
    ![](https://hackmd.io/_uploads/H1EmVZUS2.png)

8. 點選 Hosts，點擊 student 主機。
![](https://hackmd.io/_uploads/S1KnEZLHh.png)

    ![](https://hackmd.io/_uploads/HkVa4ZIS3.png)
    選擇 GROUPS，接著點選 +。
    ![](https://hackmd.io/_uploads/rJxeBWUBn.png)
    選擇 db 跟 web
    ![](https://hackmd.io/_uploads/S1KZHZ8r2.png)
    最後回到 Hosts 畫面，可以看到已經有加入 web, db groups
    ![](https://hackmd.io/_uploads/B194SZ8r3.png)

9. 完成 Inventory 建立
![](https://hackmd.io/_uploads/r1wYUZIHh.png)


10. 點選左側 `Ansible Tower Dashboard > RESOURCES > Templates`，選擇 `demo-job-template`，接著點擊右側火箭符號執行。
![](https://hackmd.io/_uploads/BkxUPWIB3.png)

11. 執行後發現失敗，由於尚未設定 Credentials，因此沒辦法存取 Student 主機。
![](https://hackmd.io/_uploads/rkhiPWIB3.png)

<div style="page-break-after: always;"></div>

## Credentials
**實作目標：建立 Ansible Tower Credentials，並使用 Credentaisl 存取管理節點。**

### 建立 Credentials - SSH Key
**實作目標：建立 Ansible Tower Credential，並使用 SSH Key 來存取管理主機。**

1. 登入 Jump Server，透過 Web Terminal 存取 ansible-execution-node 主機，複製 SSH Public Key，並將該 Key 複製到 student 主機 `.ssh/authorized_keys`。
```bash=
cat .ssh/id_rsa.pub
```
> 替代方式為在 ansible-execution-node  執行 `ssh-copy-id root@<student IP>`


2. 登入 Jump Server，透過 Web Terminal 存取到 ansible-execution-node。複製 SSH Private Key
```bash=
cat .ssh/id_rsa
```

3. 到 Ansible Tower，點選左側 `Ansible Tower Dashboard > RESOURCES > Credentials`，點擊右上角 + ，建立新的 Credential。
4. 填入 Credential 資訊，Type 選擇 Machine，輸入使用者名稱，並在 SSH PRIVATE KEY，貼上步驟 2 的 SSH Private Key。
![](https://hackmd.io/_uploads/HJs8m6KHh.png)


5. 再次執行 Job Template，點選左側 `Ansible Tower Dashboard > RESOURCES > Templates`，選擇 `demo-job-template`，接著點擊右側火箭符號執行。Credentials 選擇剛剛建立的 Credentials。
![](https://hackmd.io/_uploads/BJcN0-IHn.png)


6. 可以看到執行成功畫面。
![](https://hackmd.io/_uploads/S1fUR-UB3.png)


<div style="page-break-after: always;"></div>

## Project

1.  進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > RESOURCES > Projects`，點擊 + 建立新的 Project，並使用對應的 Organization 以及輸入 Lab SCM URL。

* Name: LAMP Project
* Organization: <依據自己的組織設定>
* SCM TYPE: Git
* SCM URL: https://github.com/redhat-tw/ansible-labs-2023.git
![](https://hackmd.io/_uploads/SJkUESPrh.png)

2. 完成後點擊同步目錄。
![](https://hackmd.io/_uploads/r1q_4SPBn.png)


<div style="page-break-after: always;"></div>

## Job template
**實作目標：建立 Ansible Tower Job Template 以及 Workflow Job Template。**

1. 登入 Jump Server，透過 Web Terminal 存取到 ansible-execution-node。進入到 Lab 目錄。
```bash=
cd ansible-labs-2023/ansible-aap
```

2. 查看 Inventory Host Var 跟 Group Var，並記錄下來。
```bash=
## Host Vars
cat inventory/hosts.ini

## Group Vars
cat inventory/group_vars/db.yml
cat inventory/group_vars/web.yml
cat inventory/group_vars/all.yml
```

3. 進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > RESOURCES > Inventories`，選擇之前建立的 Inventory，將 Host Var 跟 Group Var 分別填入到 Ansible Tower Inventory 裡。
![](https://hackmd.io/_uploads/B1ZN-BvSn.png)

    ![](https://hackmd.io/_uploads/rJYrWBvS2.png)

    ![](https://hackmd.io/_uploads/H12U-rPBn.png)


### Deploy Job Templates
1. 進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > RESOURCES > Templates`，點選 + 建立以下這些 Job Templates:

* 100-install-mariadb
    * 安裝 MariaDB
    * Playbooks: ansible-aap/100-install-mariadb.yml
* 200-install-apache
    * 安裝 httpd
    * Playbooks: ansible-aap/200-install-apache.yml
* 300-install-php
    * 安裝 PHP 並設定網頁檔
    * Playbooks: ansible-aap/300-install-php.yml
* 400-configure-db
    * 設定 MariaDB (建立網站所需的 Data)
    * Playbooks: ansible-aap/400-configure-db.yml
* 500-smoke-test
    * 測試網頁服務正常
    * Playbooks: ansible-aap/500-smoke-test.yml
* 600-stop-service
    * 停掉 MariaDB 及 httpd 服務
    * Playbooks: ansible-aap/600-stop-service.yml
* 900-uninstall
    * 解除安裝 MariaDB, httpd, PHP
    * Playbooks: ansible-aap/900-uninstall.yml

`100-install-mariadb`
![](https://hackmd.io/_uploads/Sy9MzSDBh.png)

`200-install-apache`
![](https://hackmd.io/_uploads/r1xNMHvH2.png)

`300-install-php`
![](https://hackmd.io/_uploads/BJUBfSPr3.png)

`400-configure-db`
![](https://hackmd.io/_uploads/B1kPMBwr3.png)

`500-smoke-test`
![](https://hackmd.io/_uploads/HJzOzrwr2.png)

`600-stop-service`
![](https://hackmd.io/_uploads/HkmKfSDrn.png)

`900-uninstall`
![](https://hackmd.io/_uploads/B1E9fSwBn.png)

2. 完成後，可以嘗試依序單點執行各個 Job Template。
![](https://hackmd.io/_uploads/Sy8MUHPH3.png)


3. 部署完成 LAMP 後，可以於 Jump Server，透過 Web Terminal 存取到 ansible-execution-node，嘗試連線服務。

```bash=
curl http://<student 主機 IP>:<設定的 port, 預設是 80>/employee.php
curl http://<student 主機 IP>:<設定的 port, 預設是 80>/info.php
```

### Deploy Workflow Job Templates
1. 進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > RESOURCES > Templates`，點選 + 建立以下這些 Workflow Job Templates:


* deploy-lamp-workflow
    * 部署 LAMP 服務
* remove-lamp-workflow
    * 移除 LAMP 服務

2. 建立 `deploy-lamp-workflow` Workflow Job Template。
![](https://hackmd.io/_uploads/S1JCLrvSh.png)

3. 點擊 WORKFLOW VISUALIZER，並建立以下 Workflow。
![](https://hackmd.io/_uploads/SkMXvSvBn.png)
![](https://hackmd.io/_uploads/ByMSDBDHn.png)

4. 建立 `remove-lamp-workflow` Workflow Job Template。
![](https://hackmd.io/_uploads/SJmOPrDB2.png)


5. 點擊 WORKFLOW VISUALIZER，並建立以下 Workflow。
![](https://hackmd.io/_uploads/SJeYPBPS2.png)
![](https://hackmd.io/_uploads/BJBFPSDH3.png)

6. 完成後，可以嘗試執行整個 Workflow。
![](https://hackmd.io/_uploads/Bkh2PrwHn.png)

<div style="page-break-after: always;"></div>

## RBAC

在此 Lab 會建立三種 Team:
* auditors: 稽核人員，能看到全部 Organization 資源
* development: 開發者，可以查看跟修改所有 Inventory 以及 Job Templates。也能夠使用 Inventory 及執行 Job Template。
* operation: 系統維運人員，可以使用 Inventory 及執行 Job Templates。但不可作任何變動。

| User | Team | Role  |
| -------- | -------- | -------- |
| `view_<student>_1`     | auditors     | Orgzniation Auditor  |
| `dev_<student>_1`   | development     | Inventory Admin <br /> Job Template Admin <br /> Workflow Admin <br /> Credentials Admin <br />Project Use|
| `op_<student>_1`     | operation     | Execute <br /> Inventories Use <br /> Credentials Use |

### 建立 User
1. 進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > ACCESS > Users`，點選 + 建立以下這些使用者:

* `view_<student>_1`
* `dev_<student>_1` 
* `op_<student>_1` 
![](https://hackmd.io/_uploads/Skac5BDBh.png)
    `view_<student>_1`
    ![](https://hackmd.io/_uploads/SJCacHPr3.png)
    `dev_<student>_1` 
    ![](https://hackmd.io/_uploads/ByXgiBwS3.png)
    `op_<student>_1` 
    ![](https://hackmd.io/_uploads/HkXmsBwS3.png)

### 建立 Team
1. 進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > ACCESS > Team`，點選 + 建立以下這些 Team:
* `auditors`
* `development` 
* `operation` 
![](https://hackmd.io/_uploads/HJq5srwB3.png)
    `auditors`
    ![](https://hackmd.io/_uploads/BJ6sirvHn.png)
    `development` 
    ![](https://hackmd.io/_uploads/H1kpjHvrn.png)
    `operation` 
    ![](https://hackmd.io/_uploads/S15TsSwHn.png)

### 設定 Team Member
1. 進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > ACCESS > Team`，點選任一 Team，接著點擊上方 Users，將剛剛新增的使用者加進去對應的 Groups。

    `auditors`
    ![](https://hackmd.io/_uploads/H1tq2HvSn.png)
    `development`
    ![](https://hackmd.io/_uploads/HkKBnBDr2.png)
    `operation` 
    ![](https://hackmd.io/_uploads/rknXhHPBh.png)


> 可忽略預設的使用者
### 設定 RBAC
1. 進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > ACCESS > Team`，點選任一 Team，接著點擊上方 PERMISSIONS，設定對應的權限。

2. 設定 auditors 權限
    Organization Auditors
    ![](https://hackmd.io/_uploads/rJUy6SDHn.png)
    完成
    ![](https://hackmd.io/_uploads/rkQgaHvr3.png)

3. 設定 development 權限
    Job Template Admin
    ![](https://hackmd.io/_uploads/HJINTrDBn.png)
    Workflow Admin
    ![](https://hackmd.io/_uploads/B1WSTSvr2.png)
    Inventory Admin
    ![](https://hackmd.io/_uploads/ryy8TBwS2.png)
    Project Use
    ![](https://hackmd.io/_uploads/SynYpSDH3.png)
    Credentials Admin
    ![](https://hackmd.io/_uploads/r17BxIwBn.png)
    完成
    ![](https://hackmd.io/_uploads/rJo8l8wSn.png)

4. 設定 operation 權限
    Organization Execute
    ![](https://hackmd.io/_uploads/r1hrJUDr3.png)
    Inventory Use
    ![](https://hackmd.io/_uploads/ryuwyUwB2.png)
    Credentails Use
    ![](https://hackmd.io/_uploads/ByOKxIPrn.png)
    完成
    ![](https://hackmd.io/_uploads/S1Uql8Prh.png)

5. 完成後測試用各個使用者登入確認權限是否正確。
* auditors: 稽核人員，能看到全部 Organization 資源。
* development: 開發者，可以查看跟修改所有 Inventory 以及 Job Templates。也能夠使用 Inventory 及執行 Job Template。
* operation: 系統維運人員，可以使用 Inventory 及執行 Job Templates。但不可作任何變動。