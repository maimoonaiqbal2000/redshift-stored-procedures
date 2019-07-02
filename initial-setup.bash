#!/bin/bash
echo "install psql"
yum install -y postgresql96

echo "install git"
yum -y install git

echo "setup redshift-stored-procedures repository"
cd /
git clone https://github.com/manashdeb/redshift-stored-procedures.git

echo "setup data folders"
mkdir /stockdata
chmod 777 /stockdata
mkdir /oltp_uploads
chmod 777 /oltp_uploads/
