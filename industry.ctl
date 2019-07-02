load data infile '/oltp_uploads/industry.csv' truncate into table staging.industry fields terminated by "," optionally enclosed by '"'
(INDUSTRYID,
INDUSTRY_NAME)

