

1.  Download Security Attributes from nasdaq website:
	https://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download

2.  Download historical EOD data of NASDAQ for last two months (You will need to register to the website and download is free)
	https://eoddata.com/download.aspx

3.  Login to AWS and create a security group with access on below ports for your IP:
	Redshift (5439), Oracle-RDS	(1521), SSH	(22)

4.  Create a new IAM role with below policies to grant access on S3, Glue, RedShift from EC2 instance
	AmazonS3FullAccess
	AWSGlueServiceRole
	AWSGlueServiceNotebookRole
	AWSGlueConsoleFullAccess
	AmazonRedshiftFullAccess

5.  Create a new EC2 linux instance with above security group and iam role (t2.micro will work) 
	https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LaunchInstanceWizard:

6.  Download and install Oracle XE express edition on above EC2 instance
	https://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html
	https://www.youtube.com/watch?v=zAk4wN4oHk8
	https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LaunchInstanceWizard:
	
7.  Launch a RedShift Cluster on your region (use dc2.large to be on free tier)
	https://console.aws.amazon.com/redshift/home?region=us-east-1#launch-cluster:

8.  Login to above DB EC2 instance and execute below steps:
	sudo sh initial-setup.bash
	
9.  Create an S3 bucket to keep your dataset (e.g. my-oracle-redshift-bucket)
	aws s3 mb s3://my-oracle-redshift-bucket
	https://s3.console.aws.amazon.com/s3/home?region=us-east-1
	
10. Copy downloaded files in Step No. 1 and 2 in folder /stockdata
	You may use tools like winscp or ftp to copy these companylist.csv and nasdaq*.txt files

11. Execute nasdaq_sqlldr_script to load all input data in oracle 
	sh nasdaq_sqlldr_script.bash

12. upload data files to s3
	aws s3 sync /oltp_uploads/ s3://oracle-redshift/oltp_uploads/

13. update data in RedShift (replace your redshift db parameters from step# 7 above)
	psql -h <your-redshift-endpoint> -U <redshift-master-userid> -d <redshift-databasename> -p 5439 -f redshift_setup.sql


Open AWS Glue and Create a database oltp_uploads
https://ca-central-1.console.aws.amazon.com/glue/home?region=ca-central-1#catalog:tab=databases

create a crawler and run it for S3 path s3://oracle-redshift/oltp_uploads/


add vpc end point for s3
https://docs.aws.amazon.com/glue/latest/dg/vpc-endpoints-s3.html




oracle-redshift/glue/output
s3://oracle-redshift/glue/output











powershell:
------------------------------
cd C:\shrd\aws interview\presendationData
aws s3 mb oracle-redshift
aws s3 sync . s3://oracle-redshift/eoddata


login to ec2
sudo yum search "postgresql96"

cd /oltp_uploads
sqlplus oltp/oltp @/stockdata/sql_dump_for_s3.sql
aws s3 sync . s3://oracle-redshift/oltp_uploads

cd /stockdata
aws s3 sync s3://oracle-redshift/eoddata .

sed -i '1d' *.txt
sed -i '1d' companylist.csv













sh nasdaq_sqlldr_script.bash

sqlldr oltp/oltp control=/stockdata/nasdaq_eod_price.ctl log=log_eod_price.log

sqlldr oltp/oltp control=/stockdata/nasdaq_security.ctl log=log_security.log
if above does not work, load manually using sql developer


sqlldr staging/staging control=/stockdata/security.ctl log=log_security.log
sqlldr staging/staging control=/stockdata/sector.ctl log=log_sector.log
sqlldr staging/staging control=/stockdata/industry.ctl log=log_industry.log
sqlldr staging/staging control=/stockdata/eod_price.ctl log=log_eod_price.log





SELECT column_name||',' a,CASE
	WHEN t.data_type = 'VARCHAR2' THEN '''"''||'
									 || lower(t.column_name)
									 || '||''",''||'
	ELSE lower(t.column_name)
		 || '||'',''||'
END cols FROM all_tab_columns t
WHERE t.owner = 'OLTP' AND t.table_name = 'SECTOR' ORDER BY column_id;


SELECT column_name||',' a,CASE
	WHEN t.data_type = 'VARCHAR2' THEN '''"''||'
									 || lower(t.column_name)
									 || '||''",''||'
	ELSE lower(t.column_name)
		 || '||'',''||'
END cols FROM all_tab_columns t
WHERE t.owner = 'OLTP' AND t.table_name = 'INDUSTRY' ORDER BY column_id;


SELECT column_name||',' a,CASE
	WHEN t.data_type in ('DATE','VARCHAR2') THEN '''"''||'
									 || lower(t.column_name)
									 || '||''",''||'
	ELSE lower(t.column_name)
		 || '||'',''||'
END cols FROM all_tab_columns t
WHERE t.owner = 'OLTP' AND t.table_name = 'SECURITY' ORDER BY column_id;


SELECT column_name||',' a,CASE
	WHEN t.data_type in ('DATE','VARCHAR2') THEN '''"''||'
									 || lower(t.column_name)
									 || '||''",''||'
	ELSE lower(t.column_name)
		 || '||'',''||'
END cols FROM all_tab_columns t
WHERE t.owner = 'OLTP' AND t.table_name = 'EOD_PRICE' ORDER BY column_id;

	



psql -h redshift-demo.c9acrm2tda6a.ca-central-1.redshift.amazonaws.com -U manash -d manash -p 5439 -f script.sql



export PGPASSWORD="Olap@123"
psql -h redshift-demo.c9acrm2tda6a.ca-central-1.redshift.amazonaws.com -U olap -d manash -p 5439 -w

psql -h <endpoint> -U <userid> -d <databasename> -p 5439 -f script.sql

-w -f script.sql




copy catdemo
from 's3://awssampledbuswest2/tickit/category_pipe.txt'
iam_role 'arn:aws:iam::<aws-account-id>:role/<role-name>'
region 'us-west-2';






staging	sector
staging	industry
staging	security
staging	eod_price
staging	security_data
staging	market_data
olap	market_data

SELECT * FROM SVV_TABLE_INFO i where i.schema in ('staging','olap');
select schemaname,tablename from pg_tables t where t.schemaname in ('staging','olap');


select 'drop table if exists '||schemaname||'.'||tablename from pg_tables t where t.schemaname in ('staging','olap');






COPY users_staging (id, name, city)
FROM 's3://.......'
CREDENTIALS 'aws_access_key_id=xxxxxxx;aws_secret_access_key=xxxxxxx' 
COMPUPDATE OFF STATUPDATE OFF;






















https://account.usfundamentals.com/ API key BJuaQlKFTEnc1jGJQqZyoA

https://api.usfundamentals.com/v1/companies/xbrl?companies=320193,1418091&format=json&token=your_access_token
https://api.usfundamentals.com/v1/companies/xbrl?companies=320193,1418091&format=csv&token=BJuaQlKFTEnc1jGJQqZyoA

https://api.usfundamentals.com/v1/indicators/xbrl?indicators=Goodwill,NetIncomeLoss&token=BJuaQlKFTEnc1jGJQqZyoA



stock price:
https://www.quandl.com/api/v3/datasets/EOD/AAPL.csv?api_key=YOURAPIKEY

stock fundamentals:

https://www.quandl.com/api/v3/datatables/SHARADAR/SF1.csv?ticker=AAPL&qopts.columns=ticker,dimension,datekey,revenue&api_key=TYwr8dxnsqgzXoAvzwMv
https://www.quandl.com/api/v3/datatables/SHARADAR/SF1.csv?ticker=ABIL&qopts.columns=ticker,dimension,datekey,revenue&api_key=TYwr8dxnsqgzXoAvzwMv







https://www.quandl.com/api/v3/datasets/EOD/BAC.csv?api_key=TYwr8dxnsqgzXoAvzwMv




SF1



handler.py


import json
import boto3


def hello(event, context):
    client = boto3.client('lambda')
    response=client.list_functions()
    body = {
        "message": "Go Serverless v1.0! Your function executed successfully!",
        "input": event
    }

    # response = {
    #     "statusCode": 200,
    #     "body": json.dumps(body)
    # }
    print("hi Adrik, papa is coming!")
    return response

    # Use this code if you don't use the http event with the LAMBDA-PROXY
    # integration
    """
    return {
        "message": "Go Serverless v1.0! Your function executed successfully!",
        "event": event
    }
    """





AWS::Lambda::Function	UPDATE_COMPLETE	-
HelloLambdaVersionYhNFxA6fTkBQJC6L0kOeB8nQBORGJsdchh1gUY0Yj0	arn:aws:lambda:ca-central-1:349411246714:function:hello-world-python-dev-hello:5	AWS::Lambda::Version	CREATE_COMPLETE	-
HelloLogGroup	/aws/lambda/hello-world-python-dev-hello	AWS::Logs::LogGroup	CREATE_COMPLETE	-
IamRoleLambdaExecution	hello-world-python-dev-ca-central-1-lambdaRole	AWS::IAM::Role	UPDATE_COMPLETE	-
ServerlessDeploymentBucket	hello-world-python-dev-serverlessdeploymentbucket-yjextc6b9xyc	AWS::S3::Bucket







download all historical data for last 2 months:
https://eoddata.com/symbols.aspx



https://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download
https://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download




https://www.quandl.com api key
TYwr8dxnsqgzXoAvzwMv

Fundamentals:
https://www.quandl.com/api/v3/datatables/SHARADAR/SF1.csv?api_key=TYwr8dxnsqgzXoAvzwMv

Kagl Stock Fundamentals
https://www.kaggle.com/usfundamentals/us-stocks-fundamentals/downloads/us-stocks-fundamentals.zip/3



company id and company names
https://api.usfundamentals.com/v1/companies/xbrl?format=csv&token=BJuaQlKFTEnc1jGJQqZyoA




company fundamentals
https://api.usfundamentals.com/v1/indicators/xbrl?format=csv&indicators=Goodwill,NetIncomeLoss,Assets,AssetsCurrent,CashAndCashEquivalentsAtCarryingValue,Liabilities,LiabilitiesCurrent,NetCashProvidedByUsedInFinancingActivities,NetCashProvidedByUsedInInvestingActivities,NetCashProvidedByUsedInOperatingActivities,OperatingIncomeLoss,PropertyPlantAndEquipmentNet,Revenues&token=BJuaQlKFTEnc1jGJQqZyoA


