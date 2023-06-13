1. Copy `hosts.ini` to this folder.
2. Create `group_vars` and `host_vars` folder.
3. Configure the global vars (`all.yml`) and the group vars (`linux.yml`) in `group_vars` folder.
4. Configure the host vars (`studentN.yml`) in `group_vars` folder.
5. Execute the playbooks.
```bash
ansible-playbook -i hosts.ini display_info.yml
```