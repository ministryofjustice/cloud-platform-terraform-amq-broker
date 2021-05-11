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
