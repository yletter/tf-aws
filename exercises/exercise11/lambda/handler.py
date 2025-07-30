import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda function that processes incoming events.
    
    Args:
        event (dict): The event data passed to the function.
        context (LambdaContext): The context object providing runtime information.

    Returns:
        dict: A response indicating the result of the processing.
    """
    # Extract User-Agent from headers
    user_agent = event.get('headers', {}).get('User-Agent', 'Unknown')
    logger.info(f"User-Agent header: {user_agent}")

    # Process the event data
    print("Received event: " + str(event))
    
    # Example processing logic
    response = {
        "statusCode": 200,
        "body": "New version 3.0 - Hello from Lambda!" + user_agent
    }
    
    return response
