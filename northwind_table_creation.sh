#!/bin/bash

DATABASE=""
USER=""
PASSWORD=""
HOST=""

mysql -h $HOST -u $USER -p$PASSWORD $DATABASE < northwind_creation_and_insert.sql

if [ $? -eq 0]; then
    echo "Tables created successfully"
else
    echo "ERROR: Failed to create tables" >&2
    exit 1
fi