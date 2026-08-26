# Mise Setup

This repo uses `mise` to provide a short deployment command around the AWS
Lambda deploy script.

## Requirements

Install these tools before deploying:

- `mise`
- `aws`
- `aws-vault`
- `docker` or a Docker-compatible CLI such as Podman
- `terraform`, only when managing AWS infrastructure

## AWS Deploy Credentials

The deployment workflow expects an `aws-vault` profile named
`webdyne-fortune-deploy`.

On headless Linux, use the encrypted file backend:

```bash
export AWS_VAULT_BACKEND=file
```

Store the deploy IAM user's key in aws-vault:

```bash
aws-vault add webdyne-fortune-deploy
```

Verify that the profile resolves to the deploy IAM user:

```bash
AWS_VAULT_BACKEND=file aws-vault exec webdyne-fortune-deploy -- aws sts get-caller-identity --region ap-southeast-2
```

## Mise Commands

List repo tasks:

```bash
mise tasks
```

Deploy the Lambda application image through aws-vault:

```bash
make lambda-deploy
```

`make lambda-deploy` wraps the mise task with:

```bash
AWS_VAULT_BACKEND=file aws-vault exec webdyne-fortune-deploy -- mise run deploy-lambda
```

The mise task sets:

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
