#!/usr/bin/env bash

DATABASES=$(mysql -u root --batch --skip-column-names --execute="SHOW DATABASES" | grep -v performance_schema | grep -v information_schema | grep -v mysql 2>&1)

for db in $DATABASES; do
    mysqldump -u root --single-transaction --quick --skip-comments --extended-insert --routines --triggers --databases $db > /Users/ivan/Library/Mobile\ Documents/com~apple~CloudDocs/Mackup/mysql/$db.sql
done
