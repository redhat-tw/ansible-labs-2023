#!/bin/bash
TOWER_URL="https://localhost"
TOWER_USER=""
TOWER_PASSWORD=""
USER_RESOURCE_PREFIX="student"
USERPASSWORD=(
USERPASSWORD1
USERPASSWORD2
USERPASSWORD3
USERPASSWORD4
USERPASSWORD5
USERPASSWORD6
USERPASSWORD7
USERPASSWORD8
USERPASSWORD9
USERPASSWORD10
USERPASSWORD11
USERPASSWORD12
USERPASSWORD13
USERPASSWORD14
USERPASSWORD15
)

for i in {1..15}; do

  ## Create Organizations
  curl --insecure -u "${TOWER_USER}:${TOWER_PASSWORD}" -X POST "${TOWER_URL}/api/v2/organizations/" -H "Content-Type: application/json" -d '{"name": "'"${USER_RESOURCE_PREFIX}${i}-org"'", "description": "'"Organization for ${USER_RESOURCE_PREFIX}${i}"'"}'

  ## Create Users
  curl --insecure -u "${TOWER_USER}:${TOWER_PASSWORD}" -X POST "${TOWER_URL}/api/v2/users/" -H "Content-Type: application/json" -d '{"username": "'"${STUDENT_RESOURCE_PREFIX}${i}"'", "password": "'"${USERPASSWORD[$i-1]}"'", "first_name": "'"${STUDENT_RESOURCE_PREFIX}${i}"'", "last_name": "", "email": "'"${STUDENT_RESOURCE_PREFIX}${i}@example.com"'", "is_superuser": false, "is_system_auditor": false}'

done
