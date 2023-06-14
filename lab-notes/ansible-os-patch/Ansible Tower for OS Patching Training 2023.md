# Ansible Tower for OS Patching Training 2023
###### tags: `public` `Red Hat`
[toc]

<div style="page-break-after: always;"></div>

<!--
環境提前準備:
1. 此 Lab 的 playbooks 用 manual，所以需事先在 tower 上建立好每個學員各自的 project folder，讓學員可以直接使用
2. 為了讓學員比較好查看 playbooks，每個管理主機 home 目錄也都放置一份 playbooks 目錄
3. 每個管理主機需事先放置三支服務 script 到 `/root/ansible`
4. 每個管理主機需事先裝好 LAMP Service，可使用第二堂或是第三堂課的 Script 統一部署
-->
## Lab 介紹
此 Lab 主要讓學員透過 Ansible Tower 執行 OS Patching 以及 OS Restore，並藉此了解整個 OS Patch 運作流程。

* OS Patching 流程
* OS Restore 流程

## 環境介紹
* ansible-execution-node: Ansible 節點 (Control Node)
* student 主機: 管理節點 (Managed Node)

Ansible Tower: https://awx.lab.k2rb.com

Ansible Tower Resources
| username | Organization | Role   | Project Folder |
| -------- | -------- | -------- |  -------- |
| `student1` | student1 | Organization Admin | `/var/lib/awx/projects/student1-os-patch` |
| `student2` | student2 | Organization Admin | `/var/lib/awx/projects/student2-os-patch` |
| `student3` | student3 | Organization Admin | `/var/lib/awx/projects/student3-os-patch` |
| `student4` | student4 | Organization Admin | `/var/lib/awx/projects/student4-os-patch` |
| `student5` | student5 | Organization Admin | `/var/lib/awx/projects/student5-os-patch` |
| `student6` | student6 | Organization Admin | `/var/lib/awx/projects/student6-os-patch` |
| `student7` | student7 | Organization Admin | `/var/lib/awx/projects/student7-os-patch` |
| `student8` | student8 | Organization Admin | `/var/lib/awx/projects/student8-os-patch` |
| `student9` | student9 | Organization Admin | `/var/lib/awx/projects/student9-os-patch` |
| `student10` | student10| Organization Admin | `/var/lib/awx/projects/student10-os-patch` |
| `student11` | student11| Organization Admin | `/var/lib/awx/projects/student11-os-patch` |
| `student12` | student12| Organization Admin | `/var/lib/awx/projects/student12-os-patch` |
| `student13` | student13| Organization Admin | `/var/lib/awx/projects/student13-os-patch` |
| `student14` | student14| Organization Admin | `/var/lib/awx/projects/student14-os-patch` |
| `student15` | student15| Organization Admin | `/var/lib/awx/projects/student15-os-patch` |

### 管理節點
每一台管理節點上均已經安裝 LAMP 程式，可在 Control Node 執行以下指令測試
```
curl http://<管理節點 ip>
curl http://<管理節點 ip>/info.php
curl http://<管理節點 ip>/employee.php
```

每一台管理節點的 `/root/ansible` 均已經放服務使用的 Scripts:
* startWEB.sh - 啟動 httpd 服務
* stopWEB.sh - 關閉 httpd 服務
* checkWEBVitalLog.sh - 檢查 httpd 服務是否啟動
* startDB.sh - 啟動 mariaDB 服務
* stopDB.sh - 關閉 mariaDB 服務
* checkDBVitalLog.sh - 檢查 mariaDB 服務是否啟動

## 查看環境
1. 登入 Ansible Tower
2. 選擇 `ACCESS > Organizations` 查看 Organization。每一位學生皆有自己的 Organization。 (Organization Admin)
![](https://hackmd.io/_uploads/SyogTeUBh.png)
3. 登入 Jump Server，透過 Web Terminal 存取到 ansible-execution-node
4. 在 ansible-execution-node Home 目錄應該可以看到本次 Lab 的範例檔 (`ansible-os-patch-lab-2023`)
```bash=
ls

ansible-labs-2023/ansible-os-patch
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
cd ansible-labs-2023/ansible-os-patch
```
3. 查看 Inventory，應該可以看到有三種 Inventory:
```bash=
cd inventory/sample
```
以下三種 Inventory 模擬不同環境的主機
* dev: LAMP 服務，虛擬機，且無 UFT
* uat: LAMP 服務，虛擬機，有 UFT
* prod: LAMP 服務，實體機，使用 VSR, NBU 備份


4. 將三個環境的 Inventory 建立到 Ansible Tower，進到 Tower Dashboard 點選左側 `Ansible Tower Dashboard > RESOURCES > Inventories`，點擊右上角 + ，依序建立三個新的 Inventory。

**`DEV Inventory`**
* 名稱: `<studentN>-lamp-dev`
* 組織: `<studentN>`
* 廣域變數(Global Vars):
  ```yaml=
  is_hide_log: false
  is_enable_script_debug: true
  is_force_kill_process: false
  update_yum_subcommand: update
  update_yum_extra_flags: --security
  update_retries: 3
  ```
* 群組: `ap`
    * 群組變數
    ```yaml=
    app_name: WEB
    script_home_dir: /root/ansible
    run_scripts:
    - stop: "{{ script_home_dir }}/stopWEB.sh"
      start: "{{ script_home_dir }}/startWEB.sh"
      check_vital_log: "{{ script_home_dir }}/checkWEBVitalLog.sh"

    smoke_test_urls:
    - url: "http://{{ inventory_hostname }}"
      status_code: 200

    system_services:
    - httpd
    ```
* 群組: `db`
    * 群組變數 (Group Vars)
    ```yaml=
    app_name: DB
    script_home_dir: /root/ansible
    run_scripts:
    - stop: "{{ script_home_dir }}/stopDB.sh"
      start: "{{ script_home_dir }}/startDB.sh"
      check_vital_log: "{{ script_home_dir }}/checkDBVitalLog.sh"

    system_services:
    - mariadb
    ```
* 主機: `<student 主機 IP>`
    * 主機群組: `ap`
    * 主機變數 (Host Vars)
      ```yaml=
      ansible_user: root
      ansible_connection: ssh
      machine_type: virtual

      machine_guest_name: <student N>
      vm_datacenter_name: PDISC
      vm_folder_name: "{{ machine_guest_name }}"
      ```
**`UAT Inventory`**
* 名稱: `<studentN>-lamp-uat`
* 組織: `<studentN>`
* 廣域變數(Global Vars):
  ```yaml=
  is_hide_log: false
  is_enable_script_debug: true
  is_force_kill_process: false
  update_yum_subcommand: update
  update_yum_extra_flags: --security
  update_retries: 3
  ```
* 群組: `ap`
    * 群組變數
    ```yaml=
    app_name: WEB
    script_home_dir: /root/ansible
    run_scripts:
    - stop: "{{ script_home_dir }}/stopWEB.sh"
      start: "{{ script_home_dir }}/startWEB.sh"
      check_vital_log: "{{ script_home_dir }}/checkWEBVitalLog.sh"

    smoke_test_urls:
    - url: "http://{{ inventory_hostname }}"
      status_code: 200

    system_services:
    - httpd
    ```
* 群組: `db`
    * 群組變數 (Group Vars)
    ```yaml=
    app_name: DB
    script_home_dir: /root/ansible
    run_scripts:
    - stop: "{{ script_home_dir }}/stopDB.sh"
      start: "{{ script_home_dir }}/startDB.sh"
      check_vital_log: "{{ script_home_dir }}/checkDBVitalLog.sh"

    system_services:
    - mariadb
    ```
* 群組: `uft`
    * 群組變數 (Group Vars)
    ```yaml=
    uft_git_repos:
    - url: ssh://git@10.0.9.4:7999/uftv
      name: lamp
      version: master

    uft_src_dir: /var/os-patch-ansible
    uft_dest_dir: D:\OS-Patch

    uft_data_override:
      relative_src: 測試資料_DEV\LAMP-TestData.xlsx
      relative_dest: 測試資料\LAMP-TestData.xlsx
    ```
* 主機: `<student 主機 IP>`
    * 主機群組: `ap`, `uft`
    * 主機變數 (Host Vars)
      ```yaml=
      ansible_user: root
      ansible_connection: ssh
      machine_type: virtual

      machine_guest_name: <student N>
      vm_datacenter_name: PDISC
      vm_folder_name: "{{ machine_guest_name }}"
      ```
**`PROD Inventory`**
* 名稱: `<studentN>-lamp-prod`
* 組織: `<studentN>`
* 廣域變數(Global Vars):
  ```yaml=
  is_hide_log: false
  is_enable_script_debug: true
  is_force_kill_process: false
  update_yum_subcommand: update
  update_yum_extra_flags: --security
  update_retries: 3
  ```
* 群組: `ap`
    * 群組變數
    ```yaml=
    app_name: WEB
    script_home_dir: /root/ansible
    run_scripts:
    - stop: "{{ script_home_dir }}/stopWEB.sh"
      start: "{{ script_home_dir }}/startWEB.sh"
      check_vital_log: "{{ script_home_dir }}/checkWEBVitalLog.sh"

    smoke_test_urls:
    - url: "http://{{ inventory_hostname }}"
      status_code: 200

    system_services:
    - httpd
    ```
* 群組: `db`
    * 群組變數 (Group Vars)
    ```yaml=
    app_name: DB
    script_home_dir: /root/ansible
    run_scripts:
    - stop: "{{ script_home_dir }}/stopDB.sh"
      start: "{{ script_home_dir }}/startDB.sh"
      check_vital_log: "{{ script_home_dir }}/checkDBVitalLog.sh"

    system_services:
    - mariadb
    ```
* 群組: `uft`
    * 群組變數 (Group Vars)
    ```yaml=
    uft_git_repos:
    - url: ssh://git@10.0.9.4:7999/uftv
      name: lamp
      version: master

    uft_src_dir: /var/os-patch-ansible
    uft_dest_dir: D:\OS-Patch

    uft_data_override:
      relative_src: 測試資料_DEV\LAMP-TestData.xlsx
      relative_dest: 測試資料\LAMP-TestData.xlsx
    ```
* 主機: `<student 主機 IP>`
    * 主機群組: `ap`, `uft`
    * 主機變數 (Host Vars)
      ```yaml=
      ansible_user: root
      ansible_connection: ssh

      machine_type: physical

      machine_guest_name: student01

      updated_reboot_timeout: 1800

      is_enable_vsr_backup: true
      vsr_job_id: "job-1"

      is_enable_nbu_backup: true
      nbu_wait_timeout: 3600
      nbu_backup_policy:
        name: "STUDENT01_FILE"
        type: 0
        schedule: "WEEKLY"
      nbu_master: "OMCBK01"
      nbu_results_path: "/usr/openv/netbackup/CICD_NBUBK.log"
      ```  
      
    ![](https://hackmd.io/_uploads/H1mfztV8h.png)
    
    ![](https://hackmd.io/_uploads/BktABK4Ih.png)
    
    ![](https://hackmd.io/_uploads/HyHy8F4I3.png)

    ![](https://hackmd.io/_uploads/S12OUtVUh.png)


5. 完成 Inventory 建立
![](https://hackmd.io/_uploads/B1M6LFELh.png)


## Credentials

### 建立 Credentials - SSH Key
建立 Ansible Tower Credential，並使用 SSH Key 來存取管理主機。

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
![](https://hackmd.io/_uploads/r1sguKEL2.png)


## Project

1.  進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > RESOURCES > Projects`，點擊 + 建立新的 Project，並使用對應的 Organization 以及設定 Project 路徑，在此範例我們將 Playbooks 放置 Ansible Tower 本機硬碟上，讓 Towre 透過 Manual 方式直接從硬碟取得 Playbooks。

* Name: `<studentN>-OS-Patch`
* Organization: <依據自己的組織設定>
* SCM TYPE: Manual
* Playbook Directory: `/var/lib/awx/projects/<studentN>-os-patch`
![](https://hackmd.io/_uploads/By6Fdt48n.png)


<div style="page-break-after: always;"></div>

## OS Patch Job template
建立 Ansible Tower Job Template 以及 Workflow Job Template。

### Deploy Job Templates
1. 進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > RESOURCES > Templates`，點選 + 建立以下這些 Job Templates:

    * 0100-service-stop.yml
        * 關閉服務，執行關閉服務腳本 (`stopWeb.sh`,`stopDB.sh`)
    * 0200-backup-machines.yml
        * 備份管理主機，虛擬機使用 VM Snapshot，實體機使用 NBU or VSR，因 Lab 環境限制，此 playbooks 僅顯示訊息，並不會真正執行。
    * 0300-os-patch.yml
        * 執行 OS Patching
    * 0400-service-start.yml
        * 啟動服務並檢查狀態，執行開啟及檢查服務腳本 (`startWeb.sh`,`startDB.sh`, `checkWEBVitalLog.sh`, `checkDBVitalLog.sh`)
    * 0500-smoke-testing.yml
        * 測試網頁服務正常
    * 0600-uft.yml
        * 執行 UFT 測試，因 Lab 環境限制，此 playbooks 僅顯示訊息，並不會真正執行。
    * 9000-restore-machines.yml
        * 執行 VM 快照還原，因 Lab 環境限制，此 playbooks 僅顯示訊息，並不會真正執行。


    請參照以下圖片設定 Job Template 參數:
    * NAME: `<請參照上方名稱設定>`
    * JOB Type: Run
    * Inventory: 設定 PROMPT ON LAUNCH
    * PROJECT: `<選擇前一步建立的 Project>`
    * Playbooks: `<選擇對應名稱的 Playbooks>`
    * CREDENTIALS: `<選擇前一步建立的 Credentials>`

    `0100-service-stop.yml`
    ![](https://hackmd.io/_uploads/S1_X3tNL3.png)

    `0200-backup-machines.yml`
    ![](https://hackmd.io/_uploads/SJ7S2tE83.png)

    `0300-os-patch.yml`
    ![](https://hackmd.io/_uploads/BJf83Y4Uh.png)

    `0400-service-start.yml`
    ![](https://hackmd.io/_uploads/SJlwhKVUn.png)

    `0500-smoke-testing.yml`
    ![](https://hackmd.io/_uploads/Hkld2K4I2.png)

    `0600-uft.yml`
    ![](https://hackmd.io/_uploads/SJYt2KV83.png)

    `9000-restore-machines.yml`
    ![](https://hackmd.io/_uploads/ryOchKEI2.png)

2. 完成後，可以嘗試依序單點執行各個 Job Template。
![](https://hackmd.io/_uploads/Hkl3ht4I2.png)


### Deploy Workflow Job Templates
1. 進入 Ansible Tower 點選左側 `Ansible Tower Dashboard > RESOURCES > Templates`，點選 + 建立以下這些 Workflow Job Templates:

* os-restore-workflow
    * 還原 OS 流程( OS Patching發生錯誤時)
* os-patch-workflow
    * 執行 OS Patch

2. 建立 `os-restore-workflow` Workflow Job Template。
* NAME: `os-restore-workflow`
* Organization: <依據自己的組織設定>
* Inventory: 設定 PROMPT ON LAUNCH
![](https://hackmd.io/_uploads/Hkst6FN8h.png)
    
3. 點擊 WORKFLOW VISUALIZER，並建立以下 Workflow，依序建立以下 Resources。
    * Approval: Approval-for-os-restore
    * Job Template: 0100-service-stop
    * Job Template: 9000-restore-machines
    * Approval: Approval-for-service-start
    * Job Template: 0400-service-start
    * Job Templaet: 0500-smoke-testing
    * Job template: 0600-uft
  ![](https://hackmd.io/_uploads/BkwnRt48n.png)
  ![](https://hackmd.io/_uploads/B1maCF4In.png)
 ![](https://hackmd.io/_uploads/ryp60YEI3.png)
 
4. 建立 `os-patch-workflow` Workflow Job Template。
* NAME: `os-patch-workflow`
* Organization: <依據自己的組織設定>
* Inventory: 設定 PROMPT ON LAUNCH
![](https://hackmd.io/_uploads/S1_lgq4I2.png)

5. 建立  `os-patch-workflow` Workflow Job Template 的 Survey，到 os-patch-workflow 細節頁面，點擊上方 ADD Survey，建立以下 Survey
    * YUM Update Exclude Packages
        * Variable: `update_yum_excludes`
        * Type: Multiple Choice (multiple select)
        * Multiple Choice Options
        ```
        kernel*
        redhat-release*
        kmod-kvdo*
        chkconfig
        ntsysv
        java*
        openssl*
        ```
        * Default Answer
        ```
        kernel*
        redhat-release*
        kmod-kvdo*
        chkconfig
        ntsysv
        java*
        openssl*
        ```
    * How many AP nodes need to be run simultaneously?
        * Variable: `ap_run_serial`
        * Type: Integer
        * Min: 1, Max: 10
        * Default Answer: 1    
    * How many MGR nodes need to be run simultaneously?
        * Variable: `mgr_run_serial`
        * Type: Integer
        * Min: 1, Max: 10
        * Default Answer: 1
    * How many DB nodes need to be run simultaneously?
        * Variable: `db_run_serial`
        * Type: Integer
        * Min: 1, Max: 10
        * Default Answer: 1
        
    ![](https://hackmd.io/_uploads/HyQTX54I3.png)


6. 點擊 WORKFLOW VISUALIZER，並建立以下 Workflow，依序建立以下 Resources。
    * Job Template: 0100-service-stop
    * Job Template: 0200-backup-machines
    * Approval: Approval-for-os-patch
    * Job Template: 0300-os-patch
        * 失敗進入 Job Template: os-restore-workflow
    * Approval: Approval-for-service-start
        * 失敗進入 Job Template: os-restore-workflow
    * Job Template: 0400-service-start
        * 失敗進入 Job Template: os-restore-workflow
    * Job Templaet: 0500-smoke-testing
        * 失敗進入 Job Template: os-restore-workflow
    * Job template: 0600-uft
        * 失敗進入 Job Template: os-restore-workflow

    ![](https://hackmd.io/_uploads/ryh9x5V82.png)
    ![](https://hackmd.io/_uploads/Sy_jx5EL3.png)
    ![](https://hackmd.io/_uploads/Syxnx94U3.png)


## Execute OS Patching
1. 當 Job Template 都建立完成後，可以執行整個 OS Patch Workflow
![](https://hackmd.io/_uploads/Hk_9NqVLn.png)

2. 可以嘗試以下幾種執行，查看不同執行方式的結果。
    * 用不同的 Inventory 執行
    * 設定變數
        ```yaml
        # 跳過 Service Stop
        is_skip_service_stop: true
        
        # 跳過 Backup Machines
        is_skip_backup_machine: true
        # 關閉 NBU 備份
        is_enable_nbu_backup: false
        # 關閉 VSR 備份
        is_enable_vsr_backup: false
        
        # 跳過 OS Patch
        is_skip_os_patch: true
        # 設定 OS Patch 方式 (預設是 update-minimal)
        update_yum_subcommand: update
        
        # 跳過 Service Start
        is_skip_service_start: true
        
        # 跳過 Smoke Test
        is_skip_smoke_testing: true
        
        # 跳過 UFT
        is_skip_uft: true
        
        # 跳過 Restore Machines
        is_skip_restore_machine: false
        ```

## Execute OS Restore 
若已經測試完畢 OS Patching 流程，則可測試 OS Restore 流程，可以使用以下兩種方式讓 OS Patch 流程失敗，進入到 OS Restore 流程。

* 設定錯誤的 Smoke Test URL
```yaml
smoke_test_urls:
- url: "http://{{ inventory_hostname }}"
  status_code: 200
- url: "http://{{ inventory_hostname }}/fake-url.php"
  status_code: 200
```
* Deny 掉 OS Patch Workflow 中的 Service Start Approval，進入 OS Restore


