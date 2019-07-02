INSERT INTO oltp.industry
    SELECT
        ROWNUM,
        industry
    FROM
        (
            SELECT DISTINCT
                industry
            FROM
                oltp.security_raw
        );

INSERT INTO oltp.sector
    SELECT
        ROWNUM,
        sector
    FROM
        (
            SELECT DISTINCT
                sector
            FROM
                oltp.security_raw
        );


INSERT INTO oltp.eod_price (
    symbol,
    eod_date,
    open_price,
    high_price,
    low_price,
    eod_price,
    volume
)
    SELECT
        symbol,
        TO_DATE(eod_date, 'yyyymmdd') eod_date,
        to_number(open_price),
        to_number(high_price),
        to_number(low_price),
        to_number(eod_price),
        to_number(substr(volume, 0, length(volume) - 1)) volume
    FROM
        oltp.eod_price_raw;

COMMIT;


INSERT INTO oltp.security
    SELECT
        ROWNUM,
        symbol,
        name,
        lastsale,
        marketcap,
        ipoyear,
        sectorid,
        industryid,
        updated_on
    FROM
        (
            SELECT
                symbol,
                name,
                CASE lastsale
                    WHEN 'n/a'   THEN NULL
                    ELSE to_number(lastsale)
                END lastsale,
                CASE
                    WHEN marketcap LIKE '%M' THEN 1000000 * to_number(replace(replace(replace(replace(marketcap, '$', ''), 'n/a',
                    ''), 'M', ''), 'B', ''))
                    WHEN marketcap LIKE '%B' THEN 1000000000 * to_number(replace(replace(replace(replace(marketcap, '$', ''), 'n/a'
                    , ''), 'M', ''), 'B', ''))
                    ELSE to_number(replace(replace(replace(replace(marketcap, '$', ''), 'n/a', ''), 'M', ''), 'B', ''))
                END marketcap,
                CASE ipoyear
                    WHEN 'n/a'   THEN NULL
                    ELSE to_number(ipoyear)
                END ipoyear,
                (
                    SELECT
                        sectorid
                    FROM
                        oltp.sector s
                    WHERE
                        s.sector_name = a.sector
                ) sectorid,
                (
                    SELECT
                        industryid
                    FROM
                        oltp.industry i
                    WHERE
                        i.industry_name = a.industry
                ) industryid,
                SYSDATE   updated_on
            FROM
                oltp.security_raw a
            WHERE
                symbol IN (
                    SELECT
                        symbol
                    FROM
                        oltp.eod_price
                )
        );

DELETE FROM oltp.eod_price
WHERE
    symbol NOT IN (
        SELECT
            symbol
        FROM
            oltp.security_raw
    );

COMMIT;

INSERT INTO olap.market_data (
    eod_date,
    symbol,
    open_price,
    high_price,
    low_price,
    eod_price,
    volume,
    industryid,
    industry_name,
    sectorid,
    sector_name,
    security_name,
    securityid,
    lastsale,
    marketcap,
    ipoyear
)
    SELECT
        eod_date,
        symbol,
        open_price,
        high_price,
        low_price,
        eod_price,
        volume,
        industryid,
        industry_name,
        sectorid,
        sector_name,
        security_name,
        securityid,
        lastsale,
        marketcap,
        ipoyear
    FROM
        oltp.marketview;

commit;
