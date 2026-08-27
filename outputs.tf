
output "nat_instance_eips" {
  description = "List of Elastic IP addresses used by the NAT instances. This will be empty if EIPs are provided in var.nat_instance_eip_ids or when enable_launch_before_terminating is set (see nat_instance_pool_eips)."
  value = (local.lbt_enabled || local.reuse_nat_instance_eips
    ? []
  : local.nat_instance_eips[*].public_ip)
}

output "nat_instance_pool_eips" {
  description = "Map of AZ to the pool of NAT instance EIPs used for launch-before-terminate rotation. Empty unless enable_launch_before_terminating. Add all of these to allow-lists."
  value = local.lbt_enabled ? {
    for obj in var.vpc_az_maps : obj.az => [
      for k, eip in local.nat_instance_pool_eips : eip.public_ip if local.nat_instance_pool_map[k] == obj.az
    ]
  } : {}
}

output "nat_gateway_eips" {
  description = "List of Elastic IP addresses used by the standby NAT gateways."
  value = [
    for eip in local.nat_gateway_eips
    : eip.public_ip
    if var.create_nat_gateways
  ]
}

output "nat_instance_security_group_id" {
  description = "NAT Instance Security Group ID."
  value       = aws_security_group.nat_instance.id
}

output "autoscaling_group_names" {
  description = "Name of autoscaling groups for NAT instances."
  value = [
    for asg in aws_autoscaling_group.nat_instance
    : asg.name
  ]
}
