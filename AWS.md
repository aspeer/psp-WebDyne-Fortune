# AWS Lambda Deployment

This repo can also deploy the WebDyne fortune application to AWS Lambda as a
container image.

AWS infrastructure is managed by Terraform in `infra/`. Application releases are
handled by `scripts/deploy-lambda.sh`, exposed through `make lambda-deploy`.

## Security Model

Do not use root credentials for repeated deployment.

The intended setup is:

- Terraform/bootstrap profile: used only for infrastructure changes.
- `webdyne-fortune-deploy` aws-vault profile: used for repeated image
  deployments.
- Long-lived deploy credentials: stored by `aws-vault`, not in this repo and not
  in plaintext `~/.aws/credentials`.

IAM access keys are intentionally not managed by Terraform. Terraform state can
contain secrets, so access keys stay outside the repo and outside Terraform.

## Local Credential Setup With aws-vault

Install `aws-vault` and use the encrypted file backend on headless Linux:

```bash
export AWS_VAULT_BACKEND=file
```

Store the deploy user's access key in aws-vault:

```bash
aws-vault add webdyne-fortune-deploy
```

The profile name should match the IAM deploy user managed by Terraform:
`webdyne-fortune-deployer`.

Verify the profile:

```bash
AWS_VAULT_BACKEND=file aws-vault exec webdyne-fortune-deploy -- aws sts get-caller-identity --region ap-southeast-2
```

The ARN should be:

```text
arn:aws:iam::<account-id>:user/webdyne-fortune-deployer
```

## Repeated Application Deployments

Use the limited deploy profile through `make`:

```bash
make lambda-deploy
```

This target runs `aws-vault exec webdyne-fortune-deploy -- mise run
deploy-lambda`. The underlying mise task assumes AWS credentials are already
available in the command environment.

The deploy task:

- builds `Dockerfile.lambda`
- pushes `webdyne-fortune:latest` to ECR
- updates the existing Lambda function image
- prints the Function URL

The deploy script does not create or modify IAM roles, ECR repositories, Function
URLs, invoke permissions, concurrency, or log retention. Terraform owns those
resources.

To override the aws-vault profile or backend:

```bash
make lambda-deploy AWS_VAULT_PROFILE=<profile> AWS_VAULT_BACKEND=<backend>
```

## Infrastructure

Terraform manages:

- ECR repository
- Lambda execution role and basic logging attachment
- Lambda function
- Lambda Function URL
- Lambda Function URL invoke permissions
- CloudWatch log group retention
- IAM deploy user and least-privilege deploy policy

Use Terraform only when infrastructure changes.

Terraform runtime values are declared in `infra/variables.tf`. For local
overrides, copy `infra/terraform.tfvars.example` to `infra/terraform.tfvars`.
The real `.tfvars` file is ignored by git.

Do not put AWS account IDs or credentials into Terraform variables. Account
identity is read from the active AWS profile at runtime.

From the repo root, the Makefile exposes Terraform helpers:

```bash
make terraform-init TF_AWS_PROFILE=<admin-profile>
make terraform-plan TF_AWS_PROFILE=<admin-profile>
make terraform-deploy TF_AWS_PROFILE=<admin-profile>
make lambda-url TF_AWS_PROFILE=<admin-profile>
```

`terraform-deploy` runs `terraform apply`, so use `terraform-plan` first unless
you are intentionally applying a known infrastructure change.

## First Import Of Existing Resources

The current AWS resources were created before Terraform was added. Import them
once before running `terraform plan`.

Use a bootstrap/admin AWS profile for Terraform infrastructure management. The
`webdyne-fortune-deploy` profile is intentionally limited to image pushes and
Lambda code updates, so it should not be able to create or change IAM resources.

```bash
cd infra
AWS_PROFILE=<admin-profile> terraform init

AWS_PROFILE=<admin-profile> terraform import aws_ecr_repository.app webdyne-fortune
AWS_PROFILE=<admin-profile> terraform import aws_iam_role.lambda webdyne-fortune-lambda-role
AWS_PROFILE=<admin-profile> terraform import aws_iam_role_policy_attachment.lambda_basic_execution webdyne-fortune-lambda-role/arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
AWS_PROFILE=<admin-profile> terraform import aws_cloudwatch_log_group.lambda /aws/lambda/webdyne-fortune
AWS_PROFILE=<admin-profile> terraform import aws_lambda_function.app webdyne-fortune
AWS_PROFILE=<admin-profile> terraform import aws_lambda_function_url.app webdyne-fortune
AWS_PROFILE=<admin-profile> terraform import aws_lambda_permission.function_url_public_access webdyne-fortune/FunctionURLAllowPublicAccess
AWS_PROFILE=<admin-profile> terraform import aws_lambda_permission.function_url_invoke_public_access webdyne-fortune/FunctionURLInvokeAllowPublicAccess
AWS_PROFILE=<admin-profile> terraform import aws_iam_user.deploy webdyne-fortune-deployer
account_id="$(AWS_PROFILE=<admin-profile> aws sts get-caller-identity --query Account --output text)"
AWS_PROFILE=<admin-profile> terraform import aws_iam_policy.deploy "arn:aws:iam::${account_id}:policy/webdyne-fortune-deploy-policy"
AWS_PROFILE=<admin-profile> terraform import aws_iam_user_policy_attachment.deploy "webdyne-fortune-deployer/arn:aws:iam::${account_id}:policy/webdyne-fortune-deploy-policy"
```

Alternatively, use the import helper:

```bash
cd infra
AWS_PROFILE=<admin-profile> terraform init
AWS_PROFILE=<admin-profile> ./import-existing.sh
```

Then check for drift:

```bash
AWS_PROFILE=<admin-profile> terraform plan
```

## Function URL

Read the deployed Function URL from Terraform:

```bash
make lambda-url TF_AWS_PROFILE=<admin-profile>
```
