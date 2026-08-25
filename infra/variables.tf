variable "region" {
  description = "AWS region for the Lambda deployment."
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Base name used for the Lambda function, ECR repository, IAM resources, and log group."
  type        = string
  default     = "webdyne-fortune"
}

variable "image_tag" {
  description = "Container image tag used by the Lambda function. Repeated deploys update this tag outside Terraform."
  type        = string
  default     = "latest"
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB."
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 15
}

variable "reserved_concurrency" {
  description = "Reserved concurrency for the Lambda function."
  type        = number
  default     = 10
}

variable "log_retention_days" {
  description = "CloudWatch log retention period for the Lambda log group."
  type        = number
  default     = 7
}

variable "deploy_user_name" {
  description = "IAM user used for repeated local deployments. Access keys are intentionally not managed by Terraform."
  type        = string
  default     = "webdyne-fortune-deployer"
}
