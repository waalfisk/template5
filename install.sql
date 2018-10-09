-- run the install.sql script to setup the database extensions, schema, tables, etc.
-- the database is assumed to be named 'postgres'

-- load the extensions for the database
CREATE EXTENSION
IF NOT EXISTS 
hstore;

-- schema
CREATE SCHEMA 
IF NOT EXISTS
demoschema;

-- table with hstore
CREATE TABLE 
IF NOT EXISTS 
demoschema.mytable (
    id    BIGSERIAL PRIMARY KEY,
    lali  VARCHAR(123) NOT NULL,
    hiha  NUMERIC(5,2),
    nono  hstore  
);
