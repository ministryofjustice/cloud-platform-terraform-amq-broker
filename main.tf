data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = var.cluster_state_bucket
    region = "eu-west-1"
    key    = "cloud-platform/${var.cluster_name}/terraform.tfstate"
  }
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  identifier        = "cloud-platform-${random_id.id.hex}"
  mq_admin_user     = "cp${random_string.username.result}"
  mq_admin_password = random_string.password.result
  subnets           = var.deployment_mode == "ACTIVE_STANDBY_MULTI_AZ" ? 2 : 1
}

resource "random_string" "username" {
  length  = 8
  special = false
}

resource "random_string" "password" {
  length  = 16
  special = false
}

resource "aws_security_group" "broker-sg" {
  name        = local.identifier
  description = "Allow all inbound traffic"
  vpc_id      = data.terraform_remote_state.cluster.outputs.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = data.terraform_remote_state.cluster.outputs.internal_subnets
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = data.terraform_remote_state.cluster.outputs.internal_subnets
  }
}

resource "aws_mq_broker" "broker" {
  broker_name         = local.identifier
  engine_type         = var.engine_type
  engine_version      = var.engine_version
  deployment_mode     = var.deployment_mode
  host_instance_type  = var.host_instance_type
  publicly_accessible = false
  security_groups     = [aws_security_group.broker-sg.id]

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  subnet_ids = slice(
    data.terraform_remote_state.cluster.outputs.internal_subnets_ids,
    0,
    local.subnets,
  )

  user {
    username       = local.mq_admin_user
    password       = local.mq_admin_password
    groups         = ["admin"]
    console_access = false
  }

  auto_minor_version_upgrade = false

  logs {
    general = true
    audit   = false
  }

  maintenance_window_start_time {
    day_of_week = "SUNDAY"
    time_of_day = "03:00"
    time_zone   = "UTC"
  }

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}

