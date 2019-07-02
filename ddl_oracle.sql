CREATE USER oltp IDENTIFIED BY oltp;

CREATE USER olap IDENTIFIED BY olap;

CREATE USER staging IDENTIFIED BY staging;

GRANT resource, dba TO oltp;

GRANT resource, dba TO olap;

GRANT resource, dba TO staging;


DROP TABLE oltp.eod_price_raw;

CREATE TABLE oltp.eod_price_raw (
    symbol       VARCHAR2(100),
    eod_date     VARCHAR2(100),
    open_price   VARCHAR2(100),
    high_price   VARCHAR2(100),
    low_price    VARCHAR2(100),
    eod_price    VARCHAR2(100),
    volume       VARCHAR2(100)
);

DROP TABLE oltp.security_raw;

CREATE TABLE oltp.security_raw (
    symbol      VARCHAR2(100),
    name        VARCHAR2(100),
    lastsale    VARCHAR2(100),
    marketcap   VARCHAR2(100),
    ipoyear     VARCHAR2(100),
    sector      VARCHAR2(100),
    industry    VARCHAR2(100),
    summary     VARCHAR2(100)
);

DROP TABLE oltp.eod_price;

CREATE TABLE oltp.eod_price (
    symbol       VARCHAR2(20),
    eod_date     DATE,
    open_price   NUMBER(6, 2),
    high_price   NUMBER(6, 2),
    low_price    NUMBER(6, 2),
    eod_price    NUMBER(6, 2),
    volume       NUMBER(10),
    CONSTRAINT eod_price_pk PRIMARY KEY ( symbol,
                                          eod_date )
);


DROP TABLE oltp.sector;

CREATE TABLE oltp.sector (
    sectorid      NUMBER(3)
        CONSTRAINT sector_pk PRIMARY KEY,
    sector_name   VARCHAR2(30)
        CONSTRAINT sector_name_nn NOT NULL
);


DROP TABLE oltp.industry;

CREATE TABLE oltp.industry (
    industryid      NUMBER(3)
        CONSTRAINT industry_pk PRIMARY KEY,
    industry_name   VARCHAR2(100)
        CONSTRAINT industry_name_nn NOT NULL
);

ALTER TABLE oltp.eod_price DROP CONSTRAINT eod_price_security_fk;

DROP TABLE oltp.security;

CREATE TABLE oltp.security (
    securityid   NUMBER(5)
        CONSTRAINT security_pk PRIMARY KEY,
    symbol       VARCHAR2(20)
        CONSTRAINT security_uk UNIQUE,
    name         VARCHAR2(100)
        CONSTRAINT security_name_nn NOT NULL,
    lastsale     NUMBER(10, 2),
    marketcap    NUMBER,
    ipoyear      NUMBER(4),
    sectorid     NUMBER(3)
        CONSTRAINT security_sector_fk
            REFERENCES oltp.sector ( sectorid ),
    industryid   NUMBER(3)
        CONSTRAINT security_industry_fk
            REFERENCES oltp.industry ( industryid ),
    updated_on   DATE
);

ALTER TABLE oltp.eod_price
    ADD CONSTRAINT eod_price_security_fk FOREIGN KEY ( symbol )
        REFERENCES oltp.security ( symbol );

CREATE OR REPLACE VIEW oltp.marketview AS
    SELECT
        eod_price.eod_date,
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
        security.securityid,
        security.lastsale,
        security.marketcap,
        security.ipoyear
    FROM
        oltp.eod_price,
        oltp.security,
        oltp.sector,
        oltp.industry
    WHERE
        eod_price.symbol = security.symbol
        AND security.sectorid = sector.sectorid
        AND security.industryid = industry.industryid;

DROP TABLE olap.market_data;

CREATE TABLE olap.market_data (
    eod_date        DATE,
    securityid      NUMBER(5),
    symbol          VARCHAR2(20 BYTE),
    open_price      NUMBER(6, 2),
    high_price      NUMBER(6, 2),
    low_price       NUMBER(6, 2),
    eod_price       NUMBER(6, 2),
    volume          NUMBER(10, 0),
    industryid      NUMBER(3, 0),
    industry_name   VARCHAR2(100),
    sectorid        NUMBER(3, 0),
    sector_name     VARCHAR2(30),
    security_name   VARCHAR2(100 BYTE),
    lastsale        NUMBER(10, 2),
    marketcap       NUMBER,
    ipoyear         NUMBER(4, 0)
);

GRANT SELECT, INSERT, UPDATE, DELETE ON olap.market_data TO staging;


CREATE TABLE staging.security_data (
    securityid      NUMBER(5, 0),
    symbol          VARCHAR2(20 BYTE),
    security_name   VARCHAR2(100 BYTE)
        NOT NULL ENABLE,
    lastsale        NUMBER(10, 2),
    marketcap       NUMBER,
    ipoyear         NUMBER(4, 0),
    industryid      NUMBER(3, 0),
    industry_name   VARCHAR2(100 BYTE)
        NOT NULL ENABLE,
    sectorid        NUMBER(3, 0),
    sector_name     VARCHAR2(30 BYTE)
        NOT NULL ENABLE
);



CREATE TABLE staging.eod_price
    AS
        SELECT
            *
        FROM
            oltp.eod_price
        WHERE
            1 = 2;

CREATE TABLE staging.sector
    AS
        SELECT
            *
        FROM
            oltp.sector
        WHERE
            1 = 2;

CREATE TABLE staging.industry
    AS
        SELECT
            *
        FROM
            oltp.industry
        WHERE
            1 = 2;

CREATE TABLE staging.security
    AS
        SELECT
            *
        FROM
            oltp.security
        WHERE
            1 = 2;

CREATE TABLE staging.market_data
    AS
        SELECT
            *
        FROM
            olap.market_data
        WHERE
            1 = 2;
