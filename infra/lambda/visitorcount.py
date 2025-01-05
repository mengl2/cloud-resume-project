import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloudresume-test')

def lambda_handler(event, context):
    response = table.get_item(Key={
        'id':'1'
    })
    count = response['Item']['count']
    count = count + 1
    print(count)
    response = table.put_item(Item={
        'id':'1',
        'count': count
    })
    
    return count
 

    
    
