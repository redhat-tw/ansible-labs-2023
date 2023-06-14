#!/bin/bash
ansible linux -m debug -a "msg={{ lookup('file', './file/employ_lists.json') }}"