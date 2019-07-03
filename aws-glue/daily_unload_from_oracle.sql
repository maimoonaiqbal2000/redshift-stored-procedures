set heading off;
set feedback off;
set linesize 1000;
set pages 0

spool /oltp_uploads/sector.csv;
select 
sectorid||','||
'"'||sector_name||'"' from oltp.sector;
spool off;

spool  /oltp_uploads/industry.csv; 
select
industryid||','||
'"'||industry_name||'"' from oltp.industry;
spool off;

spool  /oltp_uploads/security.csv;
select
securityid||','||
'"'||symbol||'",'||
'"'||name||'",'||
lastsale||','||
marketcap||','||
ipoyear||','||
sectorid||','||
industryid||','||
'"'||to_char(updated_on,'YYYY-MM-DD')||'"'
from oltp.security s where exists  
(select 1 from oltp.eod_price p where s.symbol=p.symbol and p.eod_date=(select max(eod_date) from oltp.eod_price));
spool off;

spool /oltp_uploads/eod_price.csv;
select
'"'||symbol||'",'||
'"'||to_char(eod_date,'YYYY-MM-DD')||'",'||
open_price||','||
high_price||','||
low_price||','||
eod_price||','||
volume
from oltp.eod_price where eod_date=(select max(eod_date) from oltp.eod_price);
spool off;

exit;


