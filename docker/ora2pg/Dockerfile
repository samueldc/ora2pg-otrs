# syntax=docker/dockerfile:1-labs
FROM dockerhub.camara.leg.br/dockerhub/library/debian:12 AS oracle_download
    RUN apt-get update \ 
        && apt-get install -y --no-install-recommends wget unzip \
        && apt-get clean
    # ADD https://download.oracle.com/otn_software/linux/instantclient/185000/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip /opt/oracle/
    # ADD https://download.oracle.com/otn_software/linux/instantclient/185000/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip /opt/oracle/
    # ADD https://download.oracle.com/otn_software/linux/instantclient/185000/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip /opt/oracle/
    # ADD https://download.oracle.com/otn_software/linux/instantclient/185000/instantclient-odbc-linux.x64-18.5.0.0.0dbru.zip /opt/oracle/
    # RUN unzip /opt/oracle/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip -d /opt/oracle/
    # RUN unzip /opt/oracle/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip -d /opt/oracle/
    # RUN unzip /opt/oracle/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip -d /opt/oracle/
    # RUN unzip /opt/oracle/instantclient-odbc-linux.x64-18.5.0.0.0dbru.zip -d /opt/oracle/
    ADD https://download.oracle.com/otn_software/linux/instantclient/1916000/instantclient-basic-linux.x64-19.16.0.0.0dbru.zip /opt/oracle/
    ADD https://download.oracle.com/otn_software/linux/instantclient/1916000/instantclient-sdk-linux.x64-19.16.0.0.0dbru.zip /opt/oracle/
    ADD https://download.oracle.com/otn_software/linux/instantclient/1916000/instantclient-sqlplus-linux.x64-19.16.0.0.0dbru.zip /opt/oracle/
    ADD https://download.oracle.com/otn_software/linux/instantclient/1916000/instantclient-odbc-linux.x64-19.16.0.0.0dbru.zip /opt/oracle/
    RUN unzip /opt/oracle/instantclient-basic-linux.x64-19.16.0.0.0dbru.zip -d /opt/oracle/ \
        && unzip /opt/oracle/instantclient-sdk-linux.x64-19.16.0.0.0dbru.zip -d /opt/oracle/ \
        && unzip /opt/oracle/instantclient-sqlplus-linux.x64-19.16.0.0.0dbru.zip -d /opt/oracle/ \
        && unzip /opt/oracle/instantclient-odbc-linux.x64-19.16.0.0.0dbru.zip -d /opt/oracle/
FROM dockerhub.camara.leg.br/dockerhub/library/debian:12
    RUN apt-get update \ 
        && apt-get install -y --no-install-recommends locales \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
        && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
    ENV LANG=en_US.utf8
    RUN apt-get update \ 
        && apt-get install -y --no-install-recommends perl \
        libdbd-mysql-perl libtimedate-perl libnet-dns-perl libcrypt-jwt-perl \
        libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl \
        libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl \
        libxml-libxml-perl libxml-libxslt-perl libyaml-perl libarchive-zip-perl \
        libcrypt-eksblowfish-perl libencode-hanextra-perl libmail-imapclient-perl \
        libtemplate-perl libdatetime-perl libmoo-perl libdbd-pg-perl \ 
        libhash-merge-perl libexcel-writer-xlsx-perl libauthen-sasl-perl \
        libcss-minifier-xs-perl libdbd-odbc-perl libauthen-ntlm-perl \
        libyaml-libyaml-perl htop bash-completion postgresql-client \
        netcat-traditional vim libaio1 libaio-dev \
        odbcinst1debian2 libodbc1 odbcinst unixodbc \
        cpanminus build-essential libtest-nowarnings-perl \
        libwww-perl ora2pg pv \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
    RUN apt-get update \
        && echo 'debconf freetds/addtoodbc select true' | debconf-set-selections \
        && DEBIAN_FRONTEND='noninteractive' apt-get install -y --no-install-recommends tdsodbc \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
    ENV ORACLE_HOME=/opt/oracle/instantclient_19_16
    ENV NLS_LANG=American_America.UTF8
    COPY --from=oracle_download $ORACLE_HOME $ORACLE_HOME
    RUN ln -s $ORACLE_HOME/libclntshcore.so.19.1 $ORACLE_HOME/libclntshcore.so \
        && ln -s $ORACLE_HOME/libsqora.so.19.1 $ORACLE_HOME/libsqora.so \
        && ORACLE_HOME=$ORACLE_HOME PATH=$PATH:$ORACLE_HOME TNS_ADMIN=$ORACLE_HOME/network/admin LD_LIBRARY_PATH=$ORACLE_HOME NLS_LANG=$NLS_LANG NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS' cpanm DBD::Oracle \
        && mkdir $ORACLE_HOME/log
    #COPY ./docker/ora2pg/.tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora
    #COPY ./docker/ora2pg/.sqlnet.ora $ORACLE_HOME/network/admin/sqlnet.ora
    # https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server
    # http://www.unixodbc.org/doc/FreeTDS.html
    RUN apt-get update \
        && apt-get install -y curl gnupg \
        && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
        && curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
        && apt-get update \
        && echo "debconf msodbcsql/ACCEPT_EULA boolean true" | debconf-set-selections \
        && echo "debconf mssql-tools/ACCEPT_EULA boolean true" | debconf-set-selections \
        && DEBIAN_FRONTEND='noninteractive' ACCEPT_EULA=Y apt-get install -y odbcinst1debian2 libodbc1 odbcinst unixodbc msodbcsql18 mssql-tools18 \
        && sed -i 's/\[ODBC Driver 18 for SQL Server\]/\[MSSQL\]/g' /etc/odbcinst.ini \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
    COPY ./docker/ora2pg/entrypoint.sh /usr/local/bin/
    RUN chmod +x /usr/local/bin/entrypoint.sh
    COPY ./docker/ora2pg/ora2pg.conf /etc/ora2pg/ora2pg.conf
    VOLUME /var/tmp
    WORKDIR /var/tmp
    COPY ./docker/ora2pg/* /var/tmp/
    ENTRYPOINT ["entrypoint.sh"]
