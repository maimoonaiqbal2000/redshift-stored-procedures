#!/bin/bash
echo "install psql"
yum install -y postgresql96
echo "setup data folders"
mkdir /stockdata
chmod 777 /stockdata
mkdir /oltp_uploads
chmod 777 /oltp_uploads/
