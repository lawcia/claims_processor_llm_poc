import json
import os
import boto3

s3 = boto3.client("s3")

def handler(event, context):
    claims = event["requestContext"]["authorizer"]["claims"]
    user_id = claims["sub"]

    filename = event["queryStringParameters"]["filename"]

    key = f"users/{user_id}/{filename}"

    url = s3.generate_presigned_url(
        ClientMethod="put_object",
        Params={
            "Bucket": os.environ["BUCKET_NAME"],
            "Key": key,
            "ContentType": "application/octet-stream"
        },
        ExpiresIn=900
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "uploadUrl": url,
            "key": key
        })
    }
