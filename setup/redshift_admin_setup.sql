drop view if exists staging.marketview;
drop table if exists staging.sector;
drop table if exists staging.industry;
drop table if exists staging.security;
drop table if exists staging.eod_price;
drop table if exists staging.security_data;
drop table if exists staging.market_data;
drop table if exists olap.market_data;
drop table if exists olap.market_data_bkp;

drop schema if exists olap;
drop schema if exists staging;
drop user if exists redshift_user;

create user redshift_user password 'Olap@123';
create schema olap authorization redshift_user;
create schema staging authorization redshift_user;

grant usage on language plpgsql to redshift_user;
grant create, usage on schema olap to redshift_user;
grant create, usage on schema staging to redshift_user;
grant all privileges on all tables in schema staging to redshift_user;
grant all privileges on all tables in schema olap to redshift_user;

