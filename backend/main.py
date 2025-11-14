import boto3
import os
import json

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = os.environ['TABLE_NAME']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    """
    Updates and retrieves the visitor count from DynamoDB.
    """
    try:
        # Atomically increment the visitor_count attribute
        response = table.update_item(
            Key={'id': 'visitor_count'},
            UpdateExpression='SET visitor_count = if_not_exists(visitor_count, :start) + :inc',
            ExpressionAttributeValues={
                ':start': 0,
                ':inc': 1
            },
            ReturnValues='UPDATED_NEW'
        )
        
        # Get the new count from the response
        new_count = response['Attributes']['visitor_count']
        
        # Return a successful response
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'visitor_count': int(new_count)})
        }
        
    except Exception as e:
        # Log the error and return an error response
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'Could not process request'})
        }
