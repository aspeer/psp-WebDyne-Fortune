IMAGE_NAME ?= webdyne-fortune
IMAGE_TAG ?= latest
PORT ?= 8080

.PHONY: docker-build docker-run lambda-deploy terraform-validate

docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run: docker-build
	docker run --rm -p $(PORT):8080 $(IMAGE_NAME):$(IMAGE_TAG)

lambda-deploy:
	mise run deploy-lambda

terraform-validate:
	terraform -chdir=infra validate
