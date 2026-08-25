output "function_url" {
  description = "Public Lambda Function URL."
  value       = aws_lambda_function_url.app.function_url
}

output "ecr_repository_url" {
  description = "ECR repository URL used by the deploy script."
  value       = aws_ecr_repository.app.repository_url
}

output "deploy_user_arn" {
  description = "IAM user used for repeated deployments."
  value       = aws_iam_user.deploy.arn
}
