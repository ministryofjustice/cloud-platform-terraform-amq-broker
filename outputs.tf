output "username" {
  value       = "${local.mq_admin_user}"
  description = "broker username"
}

output "password" {
  value       = "${local.mq_admin_password}"
  description = "broker password"
}
