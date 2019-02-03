FROM mysql:8

ENV MYSQL_ROOT_PASSWORD=localhost
ENV MYSQL_DATABASE="Todo"

COPY setup.sql /docker-entrypoint-initdb.d/
