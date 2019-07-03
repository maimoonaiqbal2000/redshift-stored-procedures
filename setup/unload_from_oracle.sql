set heading off;
set feedback off;
set linesize 1000;
set pages 0

spool sector.csv;
select
sectorid||','||
'"'||sector_name||'"' from oltp.sector;
spool off;

spool  industry.csv;
select
industryid||','||
'"'||industry_name||'"' from oltp.industry;
spool off;

spool  security.csv;
select
securityid||','||
'"'||symbol||'",'||
'"'||name||'",'||
lastsale||','||
marketcap||','||
ipoyear||','||
sectorid||','||
industryid||','||
'"'||updated_on||'"'
from oltp.security s;
spool off;

spool eod_price.csv;
select
'"'||symbol||'",'||
'"'||eod_date||'",'||
open_price||','||
high_price||','||
low_price||','||
eod_price||','||
volume
from oltp.eod_price;
spool off;

exit;
