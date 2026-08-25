#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${AWS_PROFILE:-}" ]]; then
    echo "Set AWS_PROFILE to an admin/bootstrap profile before importing." >&2
    exit 1
fi

project_name="${PROJECT_NAME:-webdyne-fortune}"
deploy_user_name="${DEPLOY_USER_NAME:-webdyne-fortune-deployer}"
deploy_policy_name="${DEPLOY_POLICY_NAME:-${project_name}-deploy-policy}"
region="${AWS_REGION:-${AWS_DEFAULT_REGION:-ap-southeast-2}}"

account_id="$(aws sts get-caller-identity --region "${region}" --query Account --output text)"
deploy_policy_arn="arn:aws:iam::${account_id}:policy/${deploy_policy_name}"
lambda_role_name="${project_name}-lambda-role"
lambda_basic_policy_arn="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

terraform import aws_ecr_repository.app "${project_name}"
terraform import aws_iam_role.lambda "${lambda_role_name}"
terraform import aws_iam_role_policy_attachment.lambda_basic_execution "${lambda_role_name}/${lambda_basic_policy_arn}"
terraform import aws_cloudwatch_log_group.lambda "/aws/lambda/${project_name}"
terraform import aws_lambda_function.app "${project_name}"
terraform import aws_lambda_function_url.app "${project_name}"
terraform import aws_lambda_permission.function_url_public_access "${project_name}/FunctionURLAllowPublicAccess"
terraform import aws_lambda_permission.function_url_invoke_public_access "${project_name}/FunctionURLInvokeAllowPublicAccess"
terraform import aws_iam_user.deploy "${deploy_user_name}"
terraform import aws_iam_policy.deploy "${deploy_policy_arn}"
terraform import aws_iam_user_policy_attachment.deploy "${deploy_user_name}/${deploy_policy_arn}"
