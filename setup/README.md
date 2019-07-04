# Step by Step Guide

This page describes step-by-step guidance on how to setup infrastructure to implement this project:
To summarize, it creates the historical stock market dataset from publicly available sources into Oracle and RedShift and then implements server less pipelines to ingest periodic dataset to the data-warehouses.

1.  Download Security Attributes from NASDAQ website:
https://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download

2.  Download historical EOD data of NASDAQ for last two months (You will need to register to the website and download is free)
https://eoddata.com/download.aspx

3.  Login to AWS and create a security group with access on below ports for your IP address:
Redshift (5439), Oracle-RDS	(1521), SSH	(22)

4.  Create a new IAM role with below policy to grant access on S3 from EC2 instance
AmazonS3FullAccess

5.  Create a new EC2 Linux instance with above security group and IAM role (t2.micro will work) 
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LaunchInstanceWizard:

6.  Download and install Oracle XE express edition on above EC2 instance
https://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html
https://www.youtube.com/watch?v=zAk4wN4oHk8
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LaunchInstanceWizard:

7.  Launch a RedShift Cluster on your region (use dc2.large to be on free tier)
https://console.aws.amazon.com/redshift/home?region=us-east-1#launch-cluster:

8.  Login to above DB EC2 instance and execute below steps:
```bash
sudo yum -y install git
sudo yum -y install postgresql96
sudo yum -y install python36
cd /
sudo rm -rvf /redshift-stored-procedures/
sudo git clone https://github.com/manashdeb/redshift-stored-procedures.git
chmod -R 755 /redshift-stored-procedures/
sudo mkdir -m 777 /stockdata
sudo mkdir -m 777 /oltp_uploads
sudo mkdir -m 777 /lambda
```

9.  Create an S3 bucket to keep your dataset (e.g. my-oracle-redshift-bucket)
aws s3 mb s3://my-oracle-redshift-bucket
https://s3.console.aws.amazon.com/s3/home?region=us-east-1

10. Copy downloaded files in Step No. 1 and 2 in folder /stockdata
You may use tools like winscp or ftp to copy these companylist.csv and nasdaq*.txt files

11. Execute nasdaq_sqlldr_script to load all input data in oracle
```bash
sh nasdaq_sqlldr_script.bash
```

12. upload data files to s3
aws s3 sync /oltp_uploads/ s3://my-oracle-redshift-bucket/oltp_uploads/

13. update data in RedShift (replace your redshift db parameters from step# 7 above)
```bash
cd /redshift-stored-procedures
psql -h <your-redshift-endpoint> -U <redshift-master-userid> -d <redshift-databasename> -p 5439 -f redshift_admin_setup.sql
export PGPASSWORD="Olap@123"
psql -h <your-redshift-endpoint> -U <redshift-master-userid> -d <redshift-databasename> -p 5439 -f redshift_user_setup.sql -w
```

14. Run Glue crawler on your S3 bucket and RedShift cluster to populate metadata tables to your glue catalog

15. Create a [glue job](../aws-glue/glue-etl-job.py) to transform and load data from S3 to Redshift

16.  Create a new IAM role with below policies to grant access on S3, Glue, RedShift from AWS Lambda
AmazonS3FullAccess
AWSGlueServiceRole
AmazonRedshiftFullAccess

17. Create [lambda function](../aws-glue/lambda_handler_glue.py) using above role in python3.6 for AWS Glue

18. Create another [lambda function](../redshift-proc/lambda_handler_redshift.py) using above role in python3.6 for AWS RedShift stored procedures

19. Configure first lambda function above to be triggered by upload events on S3 folder s3://my-oracle-redshift-bucket/notification/

20. Configure second lambda function above to be triggered by upload events on s3://my-oracle-redshift-bucket/notification2/*.txt


Congratulations, you are now ready to explore all components of these legacy vs server less data warehouse implementations

