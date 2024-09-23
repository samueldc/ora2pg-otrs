FROM dockerhub.camara.leg.br/dockerhub/library/postgres:16.4
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
COPY ./initdb.sh /docker-entrypoint-initdb.d/
COPY ./otrs.backup /docker-entrypoint-initdb.d/
# CMD [ "gosu", "postgres", "/usr/lib/postgresql/16/bin/pg_resetwal", "-f", "/var/lib/postgresql/data" ]