# cloud-platform-terraform-amq-broker

AWS MQ broker instance and credentials for the Cloud Platform

The broker instance that is created uses a randomly generated name to avoid any conflicts. Admin login is also a random user/password pair.

The module can deploy either a single or active/standby multi-AZ instance.

## Usage

```hcl
module "example_team_broker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker?ref=version"

    // The first two inputs are provided by the pipeline for cloud-platform. See the example for more detail.

  cluster_name           = "cloud-platform-live-0"
  cluster_state_bucket   = "live-0-state-bucket"
  team_name              = "example-team"
  business-unit          = "example-bu"
  application            = "exampleapp"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "example-team@digital.justice.gov.uk"
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster_name | The name of the cluster (eg.: cloud-platform-live-0) | string |  | yes |
| cluster_state_bucket | The name of the S3 bucket holding the terraform state for the cluster | string | | yes |
| engine_type | Engine used e.g. ActiveMQ, STOMP | string | ActiveMQ | |
| engine_version | The engine version to use e.g. 5.15.6 | 5.15.6 | |
| host_instance_type | The broker's instance type. e.g. mq.t2.micro or mq.m5.large | mq.t2.micro | |
| deployment_mode | The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ | SINGLE_INSTANCE | |

### Tags

Some of the inputs are tags. All infrastructure resources need to be tagged according to the [MOJ techincal guidence](https://ministryofjustice.github.io/technical-guidance/standards/documenting-infrastructure-owners/#documenting-owners-of-infrastructure). The tags are stored as variables that you will need to fill out as part of your module.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application |  | string | - | yes |
| business-unit | Area of the MOJ responsible for the service | string | `mojdigital` | yes |
| environment-name |  | string | - | yes |
| infrastructure-support | The team responsible for managing the infrastructure. Should be of the form team-email | string | - | yes |
| is-production |  | string | `false` | yes |
| team_name |  | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| primary_amqp_ssl_endpoint | amqp+ssl:// active endpoint, port 5671 |
| primary_stomp_ssl_endpoint | stomp+ssl:// active endpoint, port 61614 |
| username | admin user |
| password | admin pass |

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
