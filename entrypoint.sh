#!/bin/bash

# launch db init on background
bash /db_init.sh &

# Start SQL Server
/opt/mssql/bin/sqlservr

