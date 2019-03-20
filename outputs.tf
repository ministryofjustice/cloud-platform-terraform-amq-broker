output "primary_amqp_ssl_endpoint" {
  value       = "${broker.default.instances.0.endpoints.1}"
  description = "AmazonMQ primary AMQP+SSL endpoint"
}

output "primary_stomp_ssl_endpoint" {
  value       = "${broker.default.instances.0.endpoints.2}"
  description = "AmazonMQ primary STOMP+SSL endpoint"
}

output "username" {
  value       = "${aws_mq_broker.broker.user.username}"
  description = "broker username"
}

output "password" {
  value       = "${aws_mq_broker.broker.user.password}"
  description = "broker password"
}
