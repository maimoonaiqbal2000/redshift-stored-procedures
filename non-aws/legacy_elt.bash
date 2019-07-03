#!/bin/bash
sqlldr staging/staging control=/stockdata/security.ctl log=log_security.log
sqlldr staging/staging control=/stockdata/sector.ctl log=log_sector.log
sqlldr staging/staging control=/stockdata/industry.ctl log=log_industry.log
sqlldr staging/staging control=/stockdata/eod_price.ctl log=log_eod_price.log
sqlplus staging/staging
call staging.legacy_elt(to_date('28-JUN-2019','DD-MON-YYYY'));

