1. Copy `hosts.ini` to this folder.
2. Modify the node name in `hosts.ini`.
3. Execute the playbooks.
```bash
ansible-playbook -i hosts.ini display_info.yml
```