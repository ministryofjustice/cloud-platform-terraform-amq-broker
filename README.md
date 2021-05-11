# cloud-platform-terraform-amq-broker

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-amq-broker.svg)](https://github.com/ministryofjustice/cloud-platform-terraform-amq-broker/releases)

AWS MQ broker instance and credentials for the Cloud Platform

The broker instance that is created uses a randomly generated name to avoid any conflicts. Admin login is also a random user/password pair.

The module can deploy either a single or active/standby multi-AZ instance.

From version 2.0, the resource will by default be created in the London aws region, instead of the usual Irish one.

## Usage

```hcl
module "example_team_broker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker?ref=version"

  team_name              = "example-team"
  business-unit          = "example-bu"
  application            = "exampleapp"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "example-team@digital.justice.gov.uk"

  providers = {
    # This can be either "aws.london" or "aws.ireland:
     aws = aws.london
  }
}

```

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_mq_broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) |
| [aws_subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) |
| [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application | n/a | `any` | n/a | yes |
| aws\_region | Region into which the resource will be created. | `string` | `"eu-west-2"` | no |
| business-unit | Area of the MOJ responsible for the service | `string` | `"mojdigital"` | no |
| cluster\_name | The name of the cluster (eg.: cloud-platform-live-0) | `string` | `"live-1"` | no |
| deployment\_mode | The deployment mode of the broker. Supported: SINGLE\_INSTANCE and ACTIVE\_STANDBY\_MULTI\_AZ | `string` | `"SINGLE_INSTANCE"` | no |
| engine\_type | Engine used e.g. ActiveMQ, STOMP | `string` | `"ActiveMQ"` | no |
| engine\_version | The engine version to use e.g. 5.15.8 | `string` | `"5.15.6"` | no |
| environment-name | n/a | `any` | n/a | yes |
| host\_instance\_type | The broker's instance type. e.g. mq.t2.micro or mq.m5.large | `string` | `"mq.t2.micro"` | no |
| infrastructure-support | The team responsible for managing the infrastructure. Should be of the form <team-name> (<team-email>) | `any` | n/a | yes |
| is-production | n/a | `string` | `"false"` | no |
| namespace | n/a | `any` | n/a | yes |
| team\_name | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| password | broker password |
| primary\_amqp\_ssl\_endpoint | AmazonMQ primary AMQP+SSL endpoint |
| primary\_stomp\_ssl\_endpoint | AmazonMQ primary STOMP+SSL endpoint |
| username | broker username |

<!--- END_TF_DOCS --->

## Access outside the cluster

The broker is configured with a VPC endoint, reachable only from the cluster pods; `kubectl forward` can create an authenticated tunnel, with a 2-step process:

1. Create a forwarding pod, any small image that does TCP will do:
```
kubectl --context live-0 -n my-namespace run port-forward --generator=run-pod/v1 --image=djfaze/port-forward --port=5671 --env="REMOTE_HOST=primary-endpoint-here.eu-west-1.rds.amazonaws.com"
 --env="REMOTE_PORT=5671"
```
2. Forward the DB port
```
kubectl --context live-0 -n my-namespace port-forward port-forward 5671:80
```
With this, client tools can access via localhost
```
rabbitmqadmin -H localhost -s -P 5671 publish payload="hello, world"
```

## Reading Material

- https://docs.aws.amazon.com/amazon-mq/latest/api-reference/welcome.html
