#!/bin/bash

export DB_INIT_FOLDER="/docker-entrypoint-initdb.d"
export DB_INIT_LOG_FILE="/var/log/docker/sqlserver_db_init.log"

function echo_log {
  DATE='date +%Y/%m/%d:%H:%M:%S'
  echo `$DATE`" $1"
  echo `$DATE`" $1" >> "$DB_INIT_LOG_FILE"
}

echo_log "DB initilization start"

export STATUS=1
i=0

while [[ $STATUS -ne 0 ]] && [[ $i -lt 60 ]]; do
    echo_log "Waiting sql server availability: #iteration: $i"
	i=$i+1
	/opt/mssql-tools/bin/sqlcmd -t 1 -U ${MSSQL_USER} -P ${MSSQL_SA_PASSWORD} -Q "select 1" >> /dev/null
    sleep 1
	STATUS=$?
done

if [ $STATUS -ne 0 ]; then 
	echo_log "Error: MSSQL SERVER took more than 60 seconds to start up."
	exit 1
fi


if [ -z "$(ls -A $DB_INIT_FOLDER)" ]; then
   echo_log "there are not any *.sql script in $DB_INIT_FOLDER"
else

    for script_absolute_location in $DB_INIT_FOLDER/*.sql; do
        /opt/mssql-tools/bin/sqlcmd -S localhost -U ${MSSQL_USER} -P ${MSSQL_SA_PASSWORD} -d master -i $script_absolute_location
        if [ $? -eq 0 ]
        then
            echo_log "script $script_absolute_location was executed successfully"
        else
            echo_log "sql execution returned an error"
            break
        fi
    done
fi

echo_log "[db_init_completed]"
