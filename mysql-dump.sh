#!/usr/bin/env bash

DATABASES=$(mysql --defaults-extra-file="/Users/ivan/Library/Mobile Documents/com~apple~CloudDocs/Mackup/.my.cnf" --batch --skip-column-names --execute="SHOW DATABASES" | grep -v performance_schema | grep -v information_schema | grep -v mysql 2>&1)

for db in $DATABASES; do
    mysqldump --defaults-extra-file="/Users/ivan/Library/Mobile Documents/com~apple~CloudDocs/Mackup/.my.cnf" --single-transaction --quick --skip-comments --extended-insert --routines --triggers --databases $db > /Users/ivan/Library/Mobile\ Documents/com~apple~CloudDocs/Mackup/mysql/$db.sql
done
