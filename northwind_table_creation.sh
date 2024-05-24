#!/bin/bash

DATABASE="northwind_test"
USER=""
PASSWORD=""
HOST=""

mysql -h $HOST -u $USER -p$PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DATABASE;"

if [ $? -eq 0 ]; then
    echo "Database created successfully"
else
    echo "ERROR: Failed to create database. Check if it already exists" >&2
    exit 1
fi

mysql -h $HOST -u $USER -p$PASSWORD $DATABASE < northwind_creation_and_insert.sql

if [ $? -eq 0 ]; then
    echo "Tables created successfully"
else
    echo "ERROR: Failed to create tables" >&2
    exit 1
fi