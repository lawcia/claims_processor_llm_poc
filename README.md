# Claims Processor LLM POC

POC project to automate processing of claim documents to reduce manual effort and improve consistency

Claim documents were generated using the MAIB narrative dataset and uploaded to s3. Using a foundation model from AWS Bedrock, information can be extracted and a summary created.

The diagram below shows the architectural diagram for processing the documents. 

![Claims Processing Flow](claims_llm.drawio.png)

Userflow

Step 1: get upload URL
```
GET /upload-url?filename=my_doc.pdf
Authorization: Bearer <JWT>
```

Step 2: upload directly to S3
```
PUT <uploadUrl>
Content-Type: application/octet-stream
```

Step 3: get summary
```
GET /summary?filename=my_doc.pdf
Authorization: Bearer <JWT>
```

## Commands

Init terraform

Replace $ENV with your current env e.g. dev

```
terraform init -backend-config="key=envs/$ENV/terraform.tfstate"
```

Create terraform plan, then deploy infra

```
terraform plan -out "tfplan"
terraform apply "tfplan"
```


Install poetry

```
curl -sSL https://install.python-poetry.org | python3 -
pip install poetry-plugin-export python-inspector
```
