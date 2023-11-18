#!/bin/bash

set -e
set -u

function create_user_and_database() {
	local database=$1
	local pass=$2
	echo "  Creating user and database '$database'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	    CREATE USER $database WITH ENCRYPTED PASSWORD '$pass';
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $database;
		\c $database $POSTGRES_USER
		GRANT ALL ON SCHEMA public TO $database;
EOSQL
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
	for usr_pass in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
		user="$(echo $usr_pass | cut -d':' -f1)"
		pass="$(echo $usr_pass | cut -d':' -f2)"
		create_user_and_database $user $pass
	done
	echo "Multiple databases created"
fi