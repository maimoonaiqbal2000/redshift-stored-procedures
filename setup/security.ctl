load data infile '/oltp_uploads/security.csv' truncate into table staging.security fields terminated by "," optionally enclosed by '"' TRAILING NULLCOLS
(securityid,
symbol,
name,
lastsale,
marketcap,
ipoyear,
sectorid,
industryid,
updated_on)


