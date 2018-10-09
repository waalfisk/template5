# template5
This template installs a PostgreSQL server as container.

* Data Container: It uses a specified data volume container that might be created if it not exist yet.
* Dockerfile: There is no Dockerfile because this template uses PostgreSQL image with its default settings
* Credentials: The default settings `POSTGRES_USER=postgres`, `POSTGRES_PASSWORD=postgres` and `POSTGRES_DB=postgres` remain untouched. 

## How to use
1) Download

```
git clone git@github.com:waalfisk/template5.git mynewname
cd mynewname
```

2) Edit `config.conf` to your needs

3) Execute `./config.sh run` 

4) Access the database `postgres` as user `postgres` and start doing stuff.

## Commands
Use the following commands to install, start, or uninstall the images or container.

| command | description |
|:-------:|:-----------:|
| `./config uninstall` | Cleanup previous installations |
| `vi config.conf` | Increment the version |
| `./config.sh run` | Instantiate a new PostgreSQL container |
| `./config.sh start` | Start the Container again |
| `./config.sh check` | Display image, container and data volume |
| `./config.sh tabularasa` | Erase image, container and data volume |

Requires execution rights for `config.sh`.
For example, run `chmod u+x config.sh` to call `./config.sh ...`.
Otherwise call `bash config.sh ...`.


## Example
Access container's postgres server from host's cli 

```
psql -h localhost -p 5435 -U postgres -w
```

Here are some example commands to try

* `\copyright`
* `\h`
* `\?`
* `select schema_name from information_schema.schemata;`
* `select nspname from pg_catalog.pg_namespace;`
* `select query from pg_stat_activity;`
* `show search_path;`
* `select current_schema();`

Let's create a schema, table, and add some data
```
CREATE SCHEMA myschema;
```
(Check it with `select schema_name from information_schema.schemata;`)

Load extensions. Extensions might be required to design tables, e.g. `hstore`, `mysql_fdw`, etc.

```
CREATE EXTENSION hstore;
```

Create the demo table

```
CREATE TABLE myschema.mytable (
    id    BIGSERIAL PRIMARY KEY,
    lali  VARCHAR(123) NOT NULL,
    hiha  NUMERIC(5,2),
    nono  hstore  
);
```

Insert some observations

```
INSERT INTO myschema.mytable (lali) VALUES 
('cool stuff');

INSERT INTO myschema.mytable (lali, hiha) VALUES
('with a number (check the rounding)', 123.456);

INSERT INTO myschema.mytable (lali, nono) VALUES
('some unstructured nosql-ish hstore', '
    "thisis" => "key-value item", 
    "beaware" => "hstore does not allow sub-arrays like json",
    "mymoney" => "987.65" 
');
```

Check the table
```
SELECT * FROM myschema.mytable;

SELECT * FROM myschema.mytable
WHERE hiha IS NOT NULL;

SELECT id, lali, hiha, nono -> 'mymoney' as mycol
FROM myschema.mytable
WHERE nono -> 'mymoney' IS NOT NULL;
```

## Links
* [template5](https://github.com/waalfisk/template5)
* [postgres](https://hub.docker.com/_/postgres/) docker image
