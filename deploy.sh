#!/bin/bash
GOOS=linux go build -i -o main main.go
zip deploy.zip main

AccountID=$(aws sts get-caller-identity --output text --query Account)

# The IAM requires access to an IAM role with full access to IAM, these functions might fail
aws iam create-role \
--role-name demo-lambda-permissions \
--assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
--role-name demo-lambda-permissions \
--policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess

# These calls only require access to use Lambda, if the IAM calls above worked, then this will definitely work.
aws lambda create-function \
--region us-east-1 \
--function-name swapi-proxy \
--zip-file fileb://./deploy.zip \
--runtime go1.x \
--role arn:aws:iam::${AccountID}:role/aws-lambda-demo-role \
--handler main

aws lambda invoke \
--invocation-type RequestResponse \
--function-name swapi-proxy \
--region us-east-1 \
--log-type Tail \
--payload '{"resource":"films", "id":"1"}' \
outputfile.txt 