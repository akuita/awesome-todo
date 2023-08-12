output "access_log_bucket_id" {
  description = "The ID of the bucket for access log"
  value       = module.access_log_s3_bucket.s3_bucket_id
}

output "pipeline_artifact_bucket_id" {
  description = "The ID of the bucket for pipeline artifact"
  value       = module.pipeline_artifact_s3_bucket.s3_bucket_id
}

output "pipeline_artifact_bucket_arn" {
  description = "ARN of the bucket for pipeline artifact"
  value       = module.pipeline_artifact_s3_bucket.s3_bucket_arn
}

output "vpc_flow_log_arn" {
  description = "ARN of the bucket for vpc flow logging"
  value       = module.vpc_flow_s3_bucket.s3_bucket_arn
}

output "cloudtrail_bucket_id" {
  description = "The ID of the bucket for cloudtrail"
  value       = module.cloutrail_bucket.s3_bucket_id
}

output "athena_output_bucket_id" {
  description = "The ID of the bucket for athena"
  value       = module.athena_output_s3_bucket.s3_bucket_id
}

output "waf_bucket_arn" {
  description = "ARN of the bucket for WAF"
  value       = module.waf_bucket_delivery.s3_bucket_arn
}

output "ecs_exec_bucket_id" {
  description = "The id of the bucket for access log"
  value       = module.exec_ssh.s3_bucket_id
}

output "cloudwatch_log_groups_id" {
  description = "The id of the bucket for cloudwatch log groups"
  value       = module.cloudwatch_log_groups.s3_bucket_id
}

output "codebuild_bucket_id" {
  description = "The id of the bucket for cloudbuild"
  value       = module.codebuild_bucket_name.s3_bucket_id
}
