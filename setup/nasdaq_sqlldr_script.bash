#!/bin/bash
# this script loads all data for security and price-eod into oracle oltp schema

echo "setup table structures in Oracle"
sqlplus oltp/oltp @/redshift-stored-procedures/setup/ddl_oracle.sql

echo " create control file for sqlloader to load eod price data"
sed -i '1d' /stockdata/*.txt
sed -i '1d' /stockdata/*.csv
echo "load data" > /redshift-stored-procedures/setup/nasdaq_eod_price.ctl
for filename in /stockdata/*.txt
do
 echo "infile '$filename'" >> /redshift-stored-procedures/setup/nasdaq_eod_price.ctl
done
echo "append into table oltp.eod_price" >> /redshift-stored-procedures/setup/nasdaq_eod_price.ctl
echo "fields terminated by \",\"" >> /redshift-stored-procedures/nasdaq_eod_price.ctl
echo "(symbol,eod_date,open_price,high_price,low_price,eod_price,volume)" >> /redshift-stored-procedures/setup/nasdaq_eod_price.ctl

echo "control file definition:"
cat /redshift-stored-procedures/setup/nasdaq_eod_price.ctl

echo "loading raw eod data:"
sqlldr oltp/oltp control=/redshift-stored-procedures/setup/nasdaq_eod_price.ctl log=log_eod_price.log

echo "loading raw security data:"
sqlldr oltp/oltp control=/redshift-stored-procedures/setup/nasdaq_security.ctl log=log_security.log

echo "populating oracle tables data"
sqlplus oltp/oltp @/redshift-stored-procedures/setup/dml_oracle.sql

echo "unloading data from oracle"
sqlplus oltp/oltp @/redshift-stored-procedures/setup/unload_from_oracle.sql
