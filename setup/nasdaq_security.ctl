load data infile '/stockdata/companylist.csv' into table oltp.security_raw fields terminated by "," OPTIONALLY ENCLOSED BY '"'
(symbol char,name char,lastsale char,marketcap char,ipoyear char,sector char,industry char,summary char, abc filler)
