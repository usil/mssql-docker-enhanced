FROM mcr.microsoft.com/mssql/server

USER root
RUN mkdir -p /docker-entrypoint-initdb.d
RUN mkdir -p /var/log/docker/
RUN chown mssql /var/log/docker/

USER mssql
RUN echo ""> /var/log/docker/sqlserver_db_init.log
COPY entrypoint.sh /entrypoint.sh 
COPY db_init.sh /db_init.sh 

ENTRYPOINT ["./entrypoint.sh"]