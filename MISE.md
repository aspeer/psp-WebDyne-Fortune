# Mise Setup

This repo uses `mise` to provide a short deployment command around the AWS
Lambda deploy script.

## Requirements

Install these tools before deploying:

- `mise`
- `aws`
- `docker` or a Docker-compatible CLI such as Podman
- `gpg`
- `terraform`, only when managing AWS infrastructure

## AWS Deploy Profile

The deploy task expects an AWS CLI profile named `webdyne-fortune-deploy`.

Configure the profile from the repo root:

```bash
aws configure set region ap-southeast-2 --profile webdyne-fortune-deploy
aws configure set credential_process "$(pwd)/scripts/aws-gpg-credential-process.sh" --profile webdyne-fortune-deploy
```

Create the encrypted local deploy credentials:

```bash
scripts/init-deploy-credentials.sh
```

Verify that the profile resolves to the deploy IAM user:

```bash
AWS_PROFILE=webdyne-fortune-deploy aws sts get-caller-identity --region ap-southeast-2
```

## Mise Commands

List repo tasks:

```bash
mise tasks
```

Deploy the Lambda application image:

```bash
mise run deploy-lambda
```

The task sets:

- `AWS_PROFILE=webdyne-fortune-deploy`
- `REGION=ap-southeast-2`
- `REPO_NAME=webdyne-fortune`
- `FUNCTION_NAME=webdyne-fortune`

Terraform infrastructure tasks are exposed through the Makefile rather than
mise because they should use a separate bootstrap/admin AWS profile:

```bash
make terraform-plan TF_AWS_PROFILE=<admin-profile>
make terraform-deploy TF_AWS_PROFILE=<admin-profile>
```

## Local Overrides

Use `.mise.local.toml` for machine-local overrides. It is ignored by git.

Example:

```toml
[env]
AWS_PROFILE = "webdyne-fortune-deploy"
REGION = "ap-southeast-2"
REPO_NAME = "webdyne-fortune"
FUNCTION_NAME = "webdyne-fortune"
```

Do not store AWS access keys, secret keys, session tokens, or decrypted
credential JSON in any mise file.
