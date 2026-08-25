IMAGE_NAME ?= webdyne-fortune
IMAGE_TAG ?= latest
PORT ?= 8080
TF_AWS_PROFILE ?= default

.PHONY: docker-build docker-run lambda-deploy lambda-url terraform-init terraform-plan terraform-deploy terraform-validate

docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run: docker-build
	docker run --rm -p $(PORT):8080 $(IMAGE_NAME):$(IMAGE_TAG)

lambda-deploy:
	mise run deploy-lambda

lambda-url:
	AWS_PROFILE=$(TF_AWS_PROFILE) terraform -chdir=infra output -raw function_url

terraform-init:
	AWS_PROFILE=$(TF_AWS_PROFILE) terraform -chdir=infra init

terraform-plan:
	AWS_PROFILE=$(TF_AWS_PROFILE) terraform -chdir=infra plan

terraform-deploy:
	AWS_PROFILE=$(TF_AWS_PROFILE) terraform -chdir=infra apply

terraform-validate:
	terraform -chdir=infra validate
