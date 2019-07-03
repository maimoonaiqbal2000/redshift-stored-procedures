load data infile '/oltp_uploads/sector.csv' truncate into table staging.sector fields terminated by "," OPTIONALLY ENCLOSED BY '"'
(SECTORID,SECTOR_NAME)
