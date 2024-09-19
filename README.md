# Introduction

This is a step-by-step guide to migrate an OTRS Oracle database to a PostgreSQL database.
I'm planning to soon release a script - look foward for a "script" branch.

# Guide

## Requirements

- An environment with ora2pg installed with all its dependencies.
- This environment should have access to both Oracle and PostgreSQL databases. 

## Installation

The first step is to install ora2pg following [its official documentation](https://ora2pg.darold.net/documentation.html#INSTALLATION).

## Configuration

ora2pg configuration resides in ora2pg.conf. After installing ora2pg, a conf file will be available in ```/etc/ora2pg/ora2pg.conf```.
But you can run with any other conf file using the ```-c```` argument. Example:

```
ora2pg -c ora2pg.conf
```

This guide provides a ora2pg.conf that was successfully used to migrate a OTRS 5 database running in a Oracle 19c.

You should adjust lines below to set up the desired database connection:

```
ORACLE_DSN	dbi:Oracle:<TSN_NAME>
ORACLE_USER	<USER_NAME>
ORACLE_PWD	<USER_PASSWORD>
```

And:

```
PG_DSN		dbi:Pg:dbname=otrs;host=postgres;port=5432
PG_USER	  otrs
PG_PWD		<PG_PASSWORD>
```

The following configuration parameters were changed. Depending on you cenario, I suggest you revise each one.

```EXPORT_SCHEMA 1``` Needed for a full migration, i.e., an newly created database.

```SCHEMA <SCHEMA_NAME>``` Name of the Oracle schema. Since Oracle doesn't have schemas, this is often the name of the owner user.

```PG_SCHEMA public``` Name of the Postgres schema (I think "public" is OTRS default).

```#EXCLUDE	aaatest_copy t1 procedure.+``` Uncomment and adjust this parameter if you want to exclude some objects from the migration. In my case here, I wanted to exclude two test tables and all procedures.

```INDEXES_RENAMING	1``` Very useful to use the same name standard OTRS uses for index names.

```PG_NUMERIC_TYPE 1``` OTRS doesn't use numeric type, so leave it with 1.

```FORCE_OWNER otrs``` Otherwise ora2pg will use the Oracle user.

ora2pg does a very nice job infering most of PostgreSQL data types. 
But the rules below will result in a schema more like OTRS PostgreSQL original schema. 
All Oracle's clobs will became PostgreSQL's text. 
The only differences I found was with article.a_body, article_search.a_body, standard_template.text, sessions.data_value and xml_storage.xml_content_value
- all these fields are of type varchar (without a max size) in the OTRS PostgreSQL original schema.
But some PostgreSQL specialists said that there's no difference between text and varchar.
If you want to strictly follow OTRS PostgreSQL original schema, you could threat this in the ```MODIFY_TYPE``` parameter.

```DATA_TYPE	NUMBER(12):integer,NUMBER(5):smallint,NUMBER(20):bigint,DATE(7):timestamp(0)```

## Preparation

Check you Oracle connection (should print you Oracle dabase version):

```
ora2pg -t SHOW_VERSION -c ora2pg.conf
```

Export you Oracle schema:

```
ora2pg -t TABLE -c ora2pg.conf
```

The command above will generate a file named ```output.sql```.
Rename that file to ```output_TABLE.sql```.

For some reason I don't known, the constraints are also generate. 
But If you create the constraints before data migration, you'll violate those constraints.
You need to create the constraints only after data migration.
Edit ```output_TABLE.sql``` file and cut all the constraints creation commands and paste then in another file called ```output_CONSTRAINTS.sql```.
But you could leave the index creation commands in the ```output_TABLE.sql``` file.

Export the sequences:

```
ora2pg -t SEQUENCE -c ora2pg.conf
```

The command above will generate a file named ```output.sql```.
Rename that file to ```output_SEQUENCE.sql```. Be careful, though, to remove all
the sequences from tables that do not exist anymore like test tables, or sequences
related with tables removed after uninstalled OTRS packages.

OTRS PostgreSQL original schema uses sequences as default values for most primary keys.
But ora2pg (at least in version 23) was unable to migrate that. To workaround that,
we should generate a ```output_NEXTVAL.sql``` file with the proper commands to address that.
This file should look like this:

```
ALTER TABLE acl ALTER COLUMN id SET DEFAULT nextval('se_acl');
ALTER TABLE article ALTER COLUMN id SET DEFAULT nextval('se_article');
ALTER TABLE article_attachment ALTER COLUMN id SET DEFAULT nextval('se_article_attachment');
ALTER TABLE article_plain ALTER COLUMN id SET DEFAULT nextval('se_article_plain');
ALTER TABLE article_sender_type ALTER COLUMN id SET DEFAULT nextval('se_article_sender_type');
ALTER TABLE article_type ALTER COLUMN id SET DEFAULT nextval('se_article_type');
ALTER TABLE attachment_directory ALTER COLUMN id SET DEFAULT nextval('se_attachment_directory');
ALTER TABLE attachment_storage ALTER COLUMN id SET DEFAULT nextval('se_attachment_storage');
...
ALTER TABLE virtual_fs_db ALTER COLUMN id SET DEFAULT nextval('se_virtual_fs_db');
```

You could generate your own file or use the file provided here. Some other files
are provided here for ilustration purposes and for you convinience.

Also, the command below could be used to generate the ```output_NEXTVAL.sql``` file:

```
grep -i "CREATE TABLE" docker/httpd/output_TABLE.sql | awk '{print $3}' | xargs -I {} echo "ALTER TABLE {} ALTER COLUMN id SET DEFAULT nextval('se_{}');" >> output_NEXVAL.sql
```

## Schema and data migration

Now it's time to run the proper migration. Run the command below to create the tables and indexes (adjust the PosgreSQL host):

```
psql -h postgres -p 5432 -U otrs -d otrs -f output_TABLE.sql
```

You should also create the sequences, as the next command will try to set those values:

```
psql -h postgres -p 5432 -U otrs -d otrs -f output_SEQUENCES.sql
```

Now the most important part, copy the actual data. This step could take several
hours or days depending on you database size. In my case, this copy took 10GB/1h.

Command:

```
ora2pg -t COPY -c ora2pg.conf
```

You could copy the data table by table using the command below. In case of error, you'll better know from which table to resume from.

```
grep -i "CREATE TABLE" output_TABLE.sql | awk '{print $3}' | xargs -I {} ora2pg -t COPY -c ora2pg.conf -a 'TABLE[{}]'
```

Create the constraints:

```
psql -h postgres -p 5432 -U otrs -d otrs -f output_CONSTRAINTS.sql
```

Alter columns to set the default values based on the sequences nextval:

```
psql -h postgres -p 5432 -U otrs -d otrs -f output_NEXTVAL.sql
```

## Check

Run the command below to generante a diff report:

```
ora2pg -t TEST -c ora2pg.conf >> ora2pg_diff_report.txt
```

Analyse the report. Everything should be "ok". Until ora2pg version 23, there's
a glitch that doubles the null constraints count. And since we altered the columns
to use default values pointing to the sequences ourselves, the diff report will
also complain about that. For the same reason, Oracle sequences to autoincrement
fields will also differ.

That's it!
