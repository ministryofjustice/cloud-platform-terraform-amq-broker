output "primary_amqp_ssl_endpoint" {
  value       = "${aws_mq_broker.broker.instances.0.endpoints.1}"
  description = "AmazonMQ primary AMQP+SSL endpoint"
}

output "primary_stomp_ssl_endpoint" {
  value       = "${aws_mq_broker.broker.instances.0.endpoints.2}"
  description = "AmazonMQ primary STOMP+SSL endpoint"
}

output "username" {
  value       = "${local.mq_admin_user}"
  description = "broker username"
}

output "password" {
  value       = "${local.mq_admin_password}"
  description = "broker password"
}
