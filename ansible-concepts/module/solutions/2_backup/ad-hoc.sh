#!/bin/bash

## Backup file
ansible linux -m file -a "path={{ backup_files.dest }} state=directory"
ansible linux -m copy -a "src={{ backup_files.src }} dest={{ backup_files.dest }} remote_src=yes"

## Restore file
ansible linux -m copy -a "src={{backup_files.dest }}/{{ backup_files.src|win_basename|trim}} dest={{backup_files.src|dirname}} remote_src=true"
