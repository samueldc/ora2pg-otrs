#!/bin/bash
set -e

# Update file permissions

# Postgres environment
export PG_HOST=$PG_HOST
export PG_DATABASE=$PG_DATABASE
export PG_USER=$PG_USER
export PG_PASSWORD=$PG_PASSWORD
printf "export PG_HOST=$PG_HOST\n" >> /etc/profile
printf "export PG_DATABASE=$PG_DATABASE\n" >> /etc/profile
printf "export PG_USER=$PG_USER\n" >> /etc/profile
printf "export PG_PASSWORD=$PG_PASSWORD\n" >> /etc/profile

# Oracle environment
export ORACLE_TNS_NAME=$ORACLE_TNS_NAME
export ORACLE_USER_NAME=$ORACLE_USER_NAME
export ORACLE_USER_PASSWORD=$ORACLE_USER_PASSWORD
export ORACLE_SCHEMA_NAME=$ORACLE_SCHEMA_NAME
export NLS_LANG=$NLS_LANG
export ORACLE_HOME=$ORACLE_HOME
export TNS_ADMIN=$TNS_ADMIN
export PATH=$PATH:$ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME
printf "export ORACLE_TNS_NAME=$ORACLE_TNS_NAME\n" >> /etc/profile
printf "export ORACLE_USER_NAME=$ORACLE_USER_NAME\n" >> /etc/profile
printf "export ORACLE_USER_PASSWORD=$ORACLE_USER_PASSWORD\n" >> /etc/profile
printf "export ORACLE_SCHEMA_NAME=$ORACLE_SCHEMA_NAME\n" >> /etc/profile
printf "export NLS_LANG=$NLS_LANG\n" >> /etc/profile
printf "export ORACLE_HOME=$ORACLE_HOME\n" >> /etc/profile
printf "export TNS_ADMIN=$TNS_ADMIN\n" >> /etc/profile
printf "export PATH=$PATH\n" >> /etc/profile
printf "export LD_LIBRARY_PATH=$ORACLE_HOME\n" >> /etc/profile
ln -s ${PWD}/.tnsnames.ora $TNS_ADMIN/tnsnames.ora
ln -s ${PWD}/.sqlnet.ora $TNS_ADMIN/sqlnet.ora

# Creates postgres password file based on env variables
echo "$PG_HOST:5432:$PG_DATABASE:$PG_USER:$PG_PASSWORD" > .pgpass
chmod 0600 .pgpass

# Waits for postgres service to run up
while nc -z -w 1 $PG_HOST 5432 2> /dev/null; [[ $? -ne 0 ]]; do
  echo "Waiting postgres service";
  sleep 5;
done

# Waits for database to start up
while pg_isready -h $PG_HOST -p 5432 -U $PG_USER -d $PG_DATABASE -q 2> /dev/null; [[ $? -ne 0 ]]; do
  echo "Waiting database startup";
  sleep 5;
done

# Check flags
FLAGS=''
while getopts 'lmoic' OPTION; do
  case "$OPTION" in
    l)
      FLAGS="$OPTION"
      echo "Flags: $FLAGS"
      ;;
    ?)
      # Do nothing else
      ;;
  esac
done

# If environment is not local...
if [[ $FLAGS != 'l' ]]; then
  # Do nothing
  echo 'Do nothing...'
fi

# Replace env variables inside ora2pg.conf
sed -i "s/<ORACLE_TNS_NAME>/$ORACLE_TNS_NAME/g" ora2pg.conf
sed -i "s/<ORACLE_USER_NAME>/$ORACLE_USER_NAME/g" ora2pg.conf
sed -i "s/<ORACLE_USER_PASSWORD>/$ORACLE_USER_PASSWORD/g" ora2pg.conf
sed -i "s/<ORACLE_SCHEMA_NAME>/$ORACLE_SCHEMA_NAME/g" ora2pg.conf
sed -i "s/<PG_DATABASE>/$PG_DATABASE/g" ora2pg.conf
sed -i "s/<PG_HOST>/$PG_HOST/g" ora2pg.conf
sed -i "s/<PG_USER>/$PG_USER/g" ora2pg.conf
sed -i "s/<PG_PASSWORD>/$PG_PASSWORD/g" ora2pg.conf

# Checks ora2pg connection
ora2pg -t SHOW_VERSION -c ora2pg.conf

cat