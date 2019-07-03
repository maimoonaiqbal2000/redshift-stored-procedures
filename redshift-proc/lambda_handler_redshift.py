import pg8000
import json
import urllib.parse
import boto3

def lambda_handler_redshift(event, context):
    print('running function')
    
    parameter_eod_date = "2019-06-28"
    procedure_call="call staging.legacy_elt ('{}')".format(parameter_eod_date)
    
    print('executing procedure {}'.format(procedure_call))
    
#     execute_procedure(procedure_call)

def execute_procedure(procedure_call):
    try:
        conn=pg8000.connect(database='manash',host='redshift-demo.c9acrm2tda6a.ca-central-1.redshift.amazonaws.com', port=5439, user='redshift_user',password='Olap@123',ssl=False)
        curr=conn.cursor()
        curr.execute(procedure_call)
        curr.close()
        conn.commit()
    except Exception as err:
        print(err)
    return conn

if __name__ == "__main__":
    event = "{}"
    context = ""
    lambda_handler_redshift(event,context)
