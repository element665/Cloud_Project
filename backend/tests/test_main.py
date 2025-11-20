import pytest
from moto import mock_aws
import boto3
import os
from unittest.mock import patch
import json
from botocore.exceptions import ClientError

# Import the handler function from the main Lambda code
from backend.main import lambda_handler

@pytest.fixture
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "eu-north-1"

@pytest.fixture
def dynamodb_table(aws_credentials):
    """Create a mock DynamoDB table for testing."""
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="eu-north-1")
        table = dynamodb.create_table(
            TableName="test-visitor-count",
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            ProvisionedThroughput={"ReadCapacityUnits": 1, "WriteCapacityUnits": 1},
        )
        yield table

def test_lambda_handler_success(dynamodb_table):
    """Test the lambda_handler for a successful invocation."""
    table_name = dynamodb_table.name

    with patch.dict(os.environ, {"TABLE_NAME": table_name}):
        # 1. Test the first invocation
        response1 = lambda_handler({}, {})
        body1 = json.loads(response1["body"])

        assert response1["statusCode"] == 200
        assert body1["visitor_count"] == 1
        assert response1["headers"]["Access-Control-Allow-Origin"] == "*"

        # 2. Test the second invocation to ensure count increments
        response2 = lambda_handler({}, {})
        body2 = json.loads(response2["body"])

        assert response2["statusCode"] == 200
        assert body2["visitor_count"] == 2

        # 3. Verify the count in the mock DynamoDB table
        table_item = dynamodb_table.get_item(Key={"id": "visitor_count"})
        assert "Item" in table_item
        assert table_item["Item"]["visitor_count"] == 2

def test_lambda_handler_dynamodb_error():
    """Test the lambda_handler when a DynamoDB ClientError occurs."""
    table_name = "test-visitor-count"
    
    # Create a mock error response that mimics botocore's ClientError
    mock_error = ClientError(
        error_response={'Error': {'Code': 'ProvisionedThroughputExceededException', 'Message': 'Test error message'}},
        operation_name='UpdateItem'
    )

    with patch.dict(os.environ, {"TABLE_NAME": table_name}):
        # Patch the Table resource in the main module to raise the error
        with patch('backend.main.dynamodb.Table') as mock_table:
            mock_table.return_value.update_item.side_effect = mock_error
            
            response = lambda_handler({}, {})
            body = json.loads(response["body"])

            assert response["statusCode"] == 500
            assert "error" in body
            assert body["error"] == "Could not process request"

def test_lambda_handler_no_table_name():
    """Test the lambda_handler when the TABLE_NAME env var is not set."""
    # Ensure the environment variable is not set
    if 'TABLE_NAME' in os.environ:
        del os.environ['TABLE_NAME']

    response = lambda_handler({}, {})
    body = json.loads(response["body"])

    assert response["statusCode"] == 500
    assert "error" in body
    assert body["error"] == "Internal server configuration error"
