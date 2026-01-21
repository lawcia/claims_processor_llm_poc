import boto3
import json
from .template_manager import PromptTemplateManager

s3 = boto3.client('s3')
bedrock_runtime = boto3.client('bedrock-runtime')

SYSTEM_ROLE="You are a Insurance Claims Examiner."


def process_document(bucket, key, model_id):
    response = s3.get_object(Bucket=bucket, Key=key)
    document_text = response['Body'].read().decode('utf-8')

    manager = PromptTemplateManager()
    
    prompt = manager.get_prompt("extract_info", document_text=document_text)
    
    response = bedrock_runtime.invoke_model(
        modelId=model_id,
        body=json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "system": SYSTEM_ROLE,
            "messages": [{"role": "user", "content": prompt }],
            "max_tokens": 2000
        })
    )
    
    response_body = json.loads(response['body'].read())

    extracted_info = response_body['content'][0]['text']
    
    summary_prompt = manager.get_prompt("generate_summary", extracted_info=extracted_info)
    
    summary_response = bedrock_runtime.invoke_model(
        modelId=model_id,
        body=json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "system": SYSTEM_ROLE,
            "messages": [{"role": "user", "content": summary_prompt }],
            "max_tokens": 2000
        })
    )
    
    summary_body = json.loads(summary_response['body'].read())

    summary = summary_body['content'][0]['text']
    
    return {
        "extracted_info": extracted_info,
        "summary": summary
    }