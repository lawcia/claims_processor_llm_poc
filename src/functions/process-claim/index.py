import os
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.utilities.batch import (
    BatchProcessor,
    EventType,
    process_partial_response,
)
from aws_lambda_powertools.utilities.data_classes.sqs_event import SQSRecord
from aws_lambda_powertools.utilities.typing import LambdaContext

from utils.processor import process_document

CLAIMS_BUCKET_NAME = os.environ['CLAIMS_BUCKET_NAME']
METADATA_TABLE_NAME = os.environ['METADATA_TABLE_NAME']
INFERENCE_PROFILE_ARN = os.environ['INFERENCE_PROFILE_ARN']

processor = BatchProcessor(event_type=EventType.SQS) 
tracer = Tracer()
logger = Logger()

@tracer.capture_method
def record_handler(record: SQSRecord):  
    payload: str = record.json_body
    logger.info(payload)
    claim = process_document(bucket=CLAIMS_BUCKET_NAME, key=payload["Records"][0]["s3"]["object"]["key"], model_id=INFERENCE_PROFILE_ARN)
    summary = claim.get("summary")
    logger.info(summary)
    return summary


@logger.inject_lambda_context
@tracer.capture_lambda_handler
def handler(event, context: LambdaContext):
    return process_partial_response(  
        event=event,
        record_handler=record_handler,
        processor=processor,
        context=context,
    )

