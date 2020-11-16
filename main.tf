variable "application_name" {}

variable "environment" {}

variable "service_role_arn" {
  description = "(Required) The service role ARN that allows deployments."
}

variable "deployment_config_name" {
  default     = "CodeDeployDefault.OneAtATime"
  description = "The name of the group's deployment config. The following values are supported: CodeDeployDefault.OneAtATime, CodeDeployDefault.AllAtOnce, CodeDeployDefault.HalfAtATime"
}

#Create a topic to which to subscribe for deployment failures
resource "aws_sns_topic" "sns_deployment_failed_topic" {
  name = "${var.environment}-${var.application_name}-deploymentFailure"
}

resource "aws_codedeploy_deployment_group" "maindg" {
  app_name               = "${var.application_name}-deploy"
  deployment_group_name  = "${var.environment}"
  service_role_arn       = "${var.service_role_arn}"
  ec2_tag_filter {
    key = "CodeDeploymentGroup"
    type = "KEY_AND_VALUE"
    value = "${var.environment}-${var.application_name}"
    }

  deployment_config_name = "${var.deployment_config_name}"
  trigger_configuration {
    trigger_events = ["DeploymentFailure"]
    trigger_name = "Deployment ${var.environment}_${var.application_name} Failed"
    trigger_target_arn = "${aws_sns_topic.sns_deployment_failed_topic.arn}"
    }
}

# Output the name of the deployment group
output "deployment_group_name" {
  value = "${aws_codedeploy_deployment_group.maindg.deployment_group_name}"
}

output "deployment_group_id" {
  value = "${aws_codedeploy_deployment_group.maindg.id}"
}
