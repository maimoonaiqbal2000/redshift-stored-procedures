load data infile '/oltp_uploads/eod_price.csv' truncate into table staging.eod_price fields terminated by "," optionally enclosed by '"'
(SYMBOL char,
EOD_DATE char,
OPEN_PRICE double,
HIGH_PRICE double,
LOW_PRICE double,
EOD_PRICE double,
VOLUME double)

