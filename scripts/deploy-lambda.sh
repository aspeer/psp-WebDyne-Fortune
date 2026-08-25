#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-ap-southeast-2}"
REPO_NAME="${REPO_NAME:-webdyne-fortune}"
FUNCTION_NAME="${FUNCTION_NAME:-webdyne-fortune}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

AWS="${AWS:-aws}"
DOCKER="${DOCKER:-docker}"

account_id="$($AWS sts get-caller-identity --region "$REGION" --query Account --output text)"
ecr_host="${account_id}.dkr.ecr.${REGION}.amazonaws.com"
image_uri="${ecr_host}/${REPO_NAME}:${IMAGE_TAG}"

echo "Using AWS account ${account_id} in ${REGION}"

$AWS ecr describe-repositories \
    --region "$REGION" \
    --repository-names "$REPO_NAME" >/dev/null

echo "Building ${image_uri}"
$DOCKER build -f Dockerfile.lambda -t "${REPO_NAME}:${IMAGE_TAG}" .

echo "Logging in to ECR"
$AWS ecr get-login-password --region "$REGION" \
    | $DOCKER login --username AWS --password-stdin "$ecr_host"

echo "Pushing image"
$DOCKER tag "${REPO_NAME}:${IMAGE_TAG}" "$image_uri"
$DOCKER push "$image_uri"

echo "Updating Lambda function ${FUNCTION_NAME}"
$AWS lambda get-function \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" >/dev/null

$AWS lambda update-function-code \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" \
    --image-uri "$image_uri" >/dev/null

$AWS lambda wait function-updated \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME"

url="$($AWS lambda get-function-url-config \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" \
    --query 'FunctionUrl' \
    --output text)"

echo "Function URL: ${url}"
