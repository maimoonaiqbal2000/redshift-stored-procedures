drop view if exists staging.marketview;
drop table if exists staging.sector;
drop table if exists staging.industry;
drop table if exists staging.security;
drop table if exists staging.eod_price;
drop table if exists staging.security_data;
drop table if exists staging.market_data;
drop table if exists olap.market_data;
drop table if exists olap.market_data_bkp;

CREATE TABLE IF NOT EXISTS staging.sector (
    sectorid      INTEGER,
    sector_name   VARCHAR(30)
) BACKUP NO DISTSTYLE ALL;


CREATE TABLE IF NOT EXISTS staging.industry (
    industryid      INTEGER,
    industry_name   VARCHAR(100)
) BACKUP NO DISTSTYLE ALL;


CREATE TABLE IF NOT EXISTS staging.security (
    securityid   INTEGER,
    symbol       VARCHAR(20) DISTKEY,
    name         VARCHAR(100),
    lastsale     DOUBLE PRECISION,
    marketcap    DOUBLE PRECISION,
    ipoyear      DOUBLE PRECISION,
    sectorid     INTEGER,
    industryid   INTEGER,
    updated_on   DATE
) BACKUP NO SORTKEY (symbol);


CREATE TABLE IF NOT EXISTS staging.eod_price (
    symbol       VARCHAR(20) DISTKEY,
    eod_date     DATE,
    open_price   DOUBLE PRECISION,
    high_price   DOUBLE PRECISION,
    low_price    DOUBLE PRECISION,
    eod_price    DOUBLE PRECISION,
    volume       DOUBLE PRECISION
) BACKUP NO SORTKEY (eod_date,symbol);


CREATE TABLE IF NOT EXISTS staging.security_data (
    securityid      INTEGER,
    symbol          VARCHAR(20) DISTKEY,
    security_name   VARCHAR(100),
    lastsale        DOUBLE PRECISION,
    marketcap       BIGINT ,
    ipoyear         INTEGER,
    industryid      INTEGER,
    industry_name   VARCHAR(100),
    sectorid        INTEGER,
    sector_name     VARCHAR(30)
) BACKUP NO  SORTKEY (symbol);


CREATE TABLE IF NOT EXISTS staging.market_data (
    eod_date        DATE,
    securityid      INTEGER,
    symbol          VARCHAR(20) DISTKEY,
    open_price      DOUBLE PRECISION,
    high_price      DOUBLE PRECISION,
    low_price       DOUBLE PRECISION,
    eod_price       DOUBLE PRECISION,
    volume          DOUBLE PRECISION,
    industryid      INTEGER,
    industry_name   VARCHAR(100),
    sectorid        INTEGER,
    sector_name     VARCHAR(30),
    security_name   VARCHAR(100),
    lastsale        DOUBLE PRECISION,
    marketcap       BIGINT ,
    ipoyear         INTEGER
) BACKUP NO SORTKEY (eod_date,symbol);


CREATE TABLE IF NOT EXISTS olap.market_data (
    eod_date        DATE,
    securityid      INTEGER ENCODE zstd,
    symbol          VARCHAR(20) DISTKEY,
    open_price      DOUBLE PRECISION ENCODE zstd,
    high_price      DOUBLE PRECISION ENCODE zstd,
    low_price       DOUBLE PRECISION ENCODE zstd,
    eod_price       DOUBLE PRECISION ENCODE zstd,
    volume          DOUBLE PRECISION ENCODE zstd,
    industryid      INTEGER ENCODE zstd,
    industry_name   VARCHAR(100) ENCODE zstd,
    sectorid        INTEGER ENCODE zstd,
    sector_name     VARCHAR(30) ENCODE bytedict,
    security_name   VARCHAR(100) ENCODE zstd,
    lastsale        DOUBLE PRECISION ENCODE zstd,
    marketcap       BIGINT  ENCODE zstd,
    ipoyear         INTEGER ENCODE zstd
) SORTKEY (eod_date,symbol);


CREATE OR REPLACE VIEW staging.marketview AS
    SELECT
        eod_price.eod_date,
        security.securityid,
        eod_price.symbol,
        eod_price.open_price,
        eod_price.high_price,
        eod_price.low_price,
        eod_price.eod_price,
        eod_price.volume,
        industry.industryid,
        industry.industry_name,
        sector.sectorid,
        sector.sector_name,
        security.name   security_name,
        security.lastsale,
        security.marketcap,
        security.ipoyear
    FROM
        staging.eod_price,
        staging.security,
        staging.sector,
        staging.industry
    WHERE
        eod_price.symbol = security.symbol
        AND security.sectorid = sector.sectorid
        AND security.industryid = industry.industryid;



copy staging.sector from 's3://oracle-redshift/oltp_uploads/sector.csv' iam_role 'arn:aws:iam::349411246714:role/Redshift-S3-Quicksight' region 'ca-central-1' format as csv quote as '"';
copy staging.industry from 's3://oracle-redshift/oltp_uploads/industry.csv' iam_role 'arn:aws:iam::349411246714:role/Redshift-S3-Quicksight' region 'ca-central-1' format as csv quote as '"';
copy staging.security from 's3://oracle-redshift/oltp_uploads/security.csv' iam_role 'arn:aws:iam::349411246714:role/Redshift-S3-Quicksight' region 'ca-central-1' format as csv quote as '"' dateformat 'YYYY-MM-DD';
copy staging.eod_price from 's3://oracle-redshift/oltp_uploads/eod_price.csv' iam_role 'arn:aws:iam::349411246714:role/Redshift-S3-Quicksight' region 'ca-central-1' format as csv quote as '"' dateformat 'YYYY-MM-DD';

analyze staging.sector;
analyze staging.industry;
analyze staging.security;
analyze staging.eod_price;

create table olap.market_data_bkp as
select * from staging.marketview;
         
select schemaname,tablename from pg_tables t where t.schemaname in ('staging','olap');


