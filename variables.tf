variable "additional_instance_policies" {
  description = "Additional policies for the Alternat instance IAM role."
  type = list(object({
    policy_name = string
    policy_json = string
  }))
  default = []
}

variable "alternat_image_tag" {
  description = "The tag of the container image for the Alternat Lambda functions."
  type        = string
  default     = "latest"
}

variable "alternat_image_uri" {
  description = "The URI of the container image for the Alternat Lambda functions."
  type        = string
  default     = ""
}

variable "architecture" {
  description = "Architecture of the NAT instance image. Must be compatible with nat_instance_type."
  type        = string
  default     = "arm64"
}

variable "autoscaling_hook_function_name" {
  description = "The name to use for the autoscaling hook Lambda function."
  type        = string
  default     = "alternat-autoscaling-hook"
}

variable "create_nat_gateways" {
  description = "Whether to create the NAT Gateway and the NAT Gateway EIP in this module. If false, you must create and manage NAT Gateways separately."
  type        = bool
  default     = true
}

variable "connectivity_test_check_urls" {
  description = "List of URLs to check with the connectivity tester function."
  type        = list(string)
  default     = ["https://www.example.com", "https://www.google.com"]
}

variable "connectivity_min_success_percent" {
  description = "Minimum percentage of connectivity check URLs that must be reachable for a NAT instance route restore to proceed. Prevents a single unreachable URL from blocking restore of a healthy instance."
  type        = number
  default     = 50
  validation {
    condition     = floor(var.connectivity_min_success_percent) == var.connectivity_min_success_percent && var.connectivity_min_success_percent >= 0 && var.connectivity_min_success_percent <= 100
    error_message = "connectivity_min_success_percent must be an integer between 0 and 100."
  }
}

variable "connectivity_test_event_rule_name" {
  description = "The name to use for the event rule that invokes the connectivity test Lambda function."
  type        = string
  default     = "alternat-test-every-minute"
}

variable "connectivity_tester_function_name" {
  description = "The prefix to use for the name of the connectivity tester Lambda function. Because there is a function created in each ASG, the name will be suffixed with an index."
  type        = string
  default     = "alternat-connectivity-tester"
}

variable "enable_ec2_endpoint" {
  description = "Whether to create a VPC endpoint to EC2 for Internet Connectivity testing."
  type        = bool
  default     = true
}

variable "enable_ssm" {
  description = "Whether to enable SSM on the Alternat instances."
  type        = bool
  default     = true
}

variable "enable_nat_restore" {
  description = "Whether to enable NAT restore functionality."
  type        = bool
  default     = false
}

variable "failback_parameter_name_prefix" {
  description = <<-EOT
    Prefix of consumer-managed SSM parameters holding per-AZ failback state, as an absolute parameter
    path with no trailing slash (e.g. "/alternat/staging/failback", read as "<prefix>/<az>"). When a
    parameter reads true, the connectivity tester skips restoring that AZ's route to the NAT instance,
    so a deliberate failback is not undone by an in-flight tester run. Empty disables the check.
    Requires enable_nat_restore.
  EOT
  type        = string
  default     = ""

  validation {
    # A leading slash is required: the IAM policy builds "...:parameter${prefix}/*", and SSM
    # parameter ARNs always contain "parameter/". Expressed as a regex rather than startswith/
    # endswith so the module still works on the Terraform 1.1 floor in versions.tf.
    condition     = var.failback_parameter_name_prefix == "" || can(regex("^(/[^/]+)+$", var.failback_parameter_name_prefix))
    error_message = "failback_parameter_name_prefix must be an absolute parameter path such as \"/alternat/staging/failback\": it must start with \"/\", must not end with \"/\", and must not contain empty path segments."
  }
}

variable "ingress_security_group_ids" {
  description = "A list of security group IDs that are allowed by the NAT instance."
  type        = list(string)
  default     = []
}

variable "ingress_security_group_cidr_blocks" {
  description = "A list of CIDR blocks that are allowed by the NAT instance."
  type        = list(string)
  default     = []
}

variable "ingress_security_group_ipv6_cidr_blocks" {
  description = "A list of IPv6 CIDR blocks that are allowed by the NAT instance."
  type        = list(string)
  default     = []
}

variable "lifecycle_heartbeat_timeout" {
  description = "The length of time, in seconds, that autoscaled NAT instances should wait in the terminate state before being fully terminated."
  type        = number
  default     = 180
}

variable "max_instance_lifetime" {
  description = "Max instance life in seconds. Defaults to 14 days. Set to 0 to disable."
  type        = number
  default     = 1209600
}

variable "nat_ami" {
  description = "The AMI to use for the NAT instance. Defaults to the latest Amazon Linux 2 AMI."
  type        = string
  default     = ""
}

variable "nat_instance_block_devices" {
  description = "Optional custom EBS volume settings for the NAT instance."
  type        = any
  default     = {}
}

variable "nat_instance_root_volume_size" {
  description = "Root EBS volume size (GiB) for the NAT instance on the AL2023 Minimal AMI with the CloudWatch Agent enabled. The AL2023 root filesystem auto-grows to this size at boot, so no AMI rebuild is required to change it."
  type        = number
  default     = 3
}

variable "nat_instance_iam_profile_name" {
  description = "Name to use for the IAM profile used by the NAT instance. Must be globally unique in this AWS account. Defaults to alternat-instance- as a prefix."
  type        = string
  default     = ""
}

variable "nat_instance_iam_role_name" {
  description = "Name to use for the IAM role used by the NAT instance. Must be globally unique in this AWS account. Defaults to alternat-instance- as a prefix."
  type        = string
  default     = ""
}

variable "nat_instance_key_name" {
  description = "The name of the key pair to use for the NAT instance. This is primarily used for testing."
  type        = string
  default     = ""
}

variable "nat_instance_lifecycle_hook_role_name" {
  description = "Name to use for the IAM role used by the NAT instance lifecycle hook. Must be globally unique in this AWS account. Defaults to alternat-lifecycle-hook as a prefix."
  type        = string
  default     = ""
}

variable "nat_instance_name_prefix" {
  description = "Prefix for the NAT Auto Scaling Group and instance names. Because there is an instance created in each ASG, the name will be suffixed with an index."
  type        = string
  default     = "alternat-"
}

variable "nat_instance_sg_name_prefix" {
  description = "Prefix for the NAT instance security group name."
  type        = string
  default     = "alternat-instance"
}

variable "nat_gateway_name_prefix" {
  description = "Prefix for the standby NAT Gateway Name tag. Suffixed with the AZ name."
  type        = string
  default     = "alternat-"
}

variable "nat_gateway_eip_name" {
  description = "Name tag for the standby NAT Gateway Elastic IPs."
  type        = string
  default     = "alternat-gateway-eip"
}

variable "nat_instance_eip_name_prefix" {
  description = "Prefix for the NAT instance Elastic IP Name tag. Suffixed with an index."
  type        = string
  default     = "alternat-instance-"
}

variable "sns_topic_name_prefix" {
  description = "Prefix for the AlterNAT SNS topic name."
  type        = string
  default     = "alternat-topic"
}

variable "nat_lambda_sg_name_prefix" {
  description = "Prefix for the AlterNAT connectivity tester Lambda security group name."
  type        = string
  default     = "alternat-lambda"
}

variable "vpc_endpoint_sg_name_prefix" {
  description = "Prefix for the AlterNAT VPC endpoint security group name."
  type        = string
  default     = "ec2-vpc-endpoints-"
}

variable "nat_lambda_function_role_name" {
  description = "Name to use for the IAM role used by the replace-route Lambda function. Must be globally unique in this AWS account."
  type        = string
  default     = ""
}

variable "nat_instance_type" {
  description = "Instance type to use for NAT instances."
  type        = string
  default     = "c6gn.8xlarge"
}

variable "nat_instance_eip_ids" {
  description = <<-EOT
  Allocation IDs of Elastic IPs to associate with the NAT instances. If not specified, EIPs will be created.

  Note: if the number of EIPs does not match the number of subnets specified in `vpc_public_subnet_ids`, this variable will be ignored.
  EOT
  type        = list(string)
  default     = []
}

variable "nat_instance_supplement_eip_ids" {
  description = "Allocation IDs of pre-provisioned supplemental EIPs (pool member 1) for launch-before-terminating, one per AZ aligned with vpc_az_maps. If provided (and matching the AZ count), these are used instead of creating supplements — useful for reserving and allow-listing the IPs before migration. Only used when enable_launch_before_terminating is set."
  type        = list(string)
  default     = []
}

variable "fallback_ngw_eip_allocation_ids" {
  type        = map(string)
  default     = {}
  description = "Explicitly specified allocation_ids for fallback NAT Gateway by AZ (e.g., { eu-west-1a = \"eipalloc-0123456789abcdef0\" }). If specified for an AZ, the EIP will not be created automatically."
  validation {
    condition     = alltrue([for v in values(var.fallback_ngw_eip_allocation_ids) : can(regex("^eipalloc-[0-9a-f]+$", v))])
    error_message = "Each allocation_id must be in the format eipalloc-xxxxxxxxxxxxxxx (hex)."
  }
}

variable "nat_instance_user_data_pre_install" {
  description = "Pre-install shell script to run at boot before configuring alternat."
  type        = string
  default     = ""
}

variable "nat_instance_user_data_post_install" {
  description = "Post-install shell script to run at boot after configuring alternat."
  type        = string
  default     = ""
}

variable "permissions_boundary" {
  description = "ARN of a policy to attach as the permissions boundary on every IAM role created by this module. Required when the caller's own permissions are delegated via a boundary that conditions IAM writes on iam:PermissionsBoundary."
  type        = string
  default     = null
}

variable "prevent_destroy_eips" {
  description = "Prevents accidental destruction of EIPs by setting `prevent_destroy=true`"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all supported resources managed by the module."
  type        = map(string)
  default     = {}
}

variable "vpc_az_maps" {
  description = "A map of az to private route tables that the NAT instances will manage."
  type = list(object({
    az                 = string
    private_subnet_ids = list(string)
    public_subnet_id   = string
    route_table_ids    = list(string)
  }))
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID to use for fallback. If not provided, the gateway in the same subnet as relevant NAT instance is selected."
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "lambda_package_type" {
  description = "The lambda deployment package type. Valid values are \"Zip\" and \"Image\". Defaults to \"Image\"."
  type        = string
  default     = "Image"
  nullable    = false

  validation {
    condition     = contains(["Zip", "Image"], var.lambda_package_type)
    error_message = "Must be a supported package type: \"Zip\" or \"Image\"."
  }
}

variable "lambda_memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 256."
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Amount of time your Lambda Function has to run in seconds. Defaults to 300."
  type        = number
  default     = 300
}

variable "lambda_handlers" {
  description = "Lambda handlers."
  type = object({
    connectivity_tester       = string,
    alternat_autoscaling_hook = string,
  })
  default = {
    connectivity_tester       = "app.connectivity_test_handler",
    alternat_autoscaling_hook = "app.handler"
  }
}

variable "lambda_environment_variables" {
  description = "Environment variables to be provided to the lambda function."
  type        = map(string)
  default     = null
}

variable "lambda_has_ipv6" {
  description = "Controls whether or not the lambda function can use IPv6."
  type        = bool
  default     = true
}

variable "lambda_zip_path" {
  description = "The location where the generated zip file should be stored. Required when `lambda_package_type` is \"Zip\"."
  type        = string
  default     = "/tmp/alternat-lambda.zip"
}

variable "lambda_function_architectures" {
  description = "CPU architecture(s) to use for the lambda functions."
  type        = list(string)
  default     = ["x86_64"]
}

variable "lambda_layer_arns" {
  type        = list(string)
  description = "List of Lambda layers ARN that will be added to functions"
  default     = null
}

variable "enable_cloudwatch_agent" {
  description = "Whether to enable CloudWatch Agent on the NAT instances."
  type        = bool
  default     = false
}

variable "cloudwatch_namespace" {
  description = "The name of the CloudWatch namespace for the CloudWatch Agent"
  type        = string
  default     = "alterNAT"
}

variable "cloudwatch_interfaces" {
  description = "List of NAT instance interfaces that should be monitored by the CloudWatch Agent"
  type        = list(string)
  default     = ["ens5", "ens6"]
}

variable "enable_launch_script_lifecycle_hook" {
  description = "Whether to enable the ASG lifecycle hook for the launch script."
  type        = bool
  default     = false
}

variable "wait_for_capacity_timeout" {
  description = "How long Terraform waits for the ASG to reach desired capacity. Set to \"0\" to make apply non-blocking (recommended for production to avoid hung applies during rolling instance replacements)."
  type        = string
  default     = "10m"
}

variable "enable_launch_before_terminating" {
  description = "Launch a replacement NAT instance before terminating the old one (ASG instance maintenance policy 100/200). Uses a pool of 2 EIPs per AZ so the replacement always has a free EIP to claim; the AZ alternates between its two EIPs each rotation. Pool member 0 is either module-created or, when nat_instance_eip_ids is provided (one per AZ), the supplied EIP (e.g. a preserved NAT gateway EIP). Pool member 1 (the supplement) is module-created unless nat_instance_supplement_eip_ids is provided. Both EIPs exist up front so they can be added to allow-lists in advance."
  type        = bool
  default     = false
}
