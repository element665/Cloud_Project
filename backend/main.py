import boto3
import os
import json
import logging
from botocore.exceptions import ClientError

# Initialize logger and set log level
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB client outside the handler for performance reuse
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    """
    Updates and retrieves the visitor count from DynamoDB.
    """
    table_name = os.environ.get('TABLE_NAME')
    if not table_name:
        logger.error("Environment variable TABLE_NAME not set.")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'Internal server configuration error'})
        }

    table = dynamodb.Table(table_name)
    
    try:
        # Atomically increment the visitor_count attribute
        response = table.update_item(
            Key={'id': 'visitor_count'},
            UpdateExpression='ADD visitor_count :inc',
            ExpressionAttributeValues={
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
        
    except ClientError as e:
        # Log the specific DynamoDB error and return an error response
        logger.error(f"DynamoDB ClientError: {e.response['Error']['Message']}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'Could not process request'})
        }
    except Exception as e:
        # Catch any other unexpected errors
        logger.error(f"An unexpected error occurred: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-control-allow-origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'An unexpected server error occurred'})
        }
