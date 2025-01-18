import os

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": f"Environment Variable: {os.getenv('ENV_VAR')}"
    }
