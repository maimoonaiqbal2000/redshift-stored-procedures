import json
import urllib.parse
import boto3

def lambda_handler_glue(event, context):
    print('Loading function')
    
    s3 = boto3.client('s3')
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    print("Notification file name: s3://{}/{}".format(bucket,key))

    glue = boto3.client('glue')
    glue_job_name = "redshift-etl-job"
    print("Starting glue job :{}".format(glue_job_name))
    glue.start_job_run(JobName = glue_job_name,Arguments = {})
    return {'statusCode':200,'body': json.dumps("Succcess")}

if __name__ == "__main__":
    event = { "Records": [ { "s3": { "bucket": { "name": "oracle-redshift", "ownerIdentity": { "principalId": "EXAMPLE" }, "arn": "arn:aws:s3:::oracle-redshift" }, "object": { "key": "notification/notification.txt", "size": 1024, "eTag": "0123456789abcdef0123456789abcdef", "sequencer": "0A1B2C3D4E5F678901" } } } ] }
    context = ""
    lambda_handler_glue(event,context)
