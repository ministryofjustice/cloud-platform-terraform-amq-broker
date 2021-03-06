/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "example_team_broker" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker?ref=3.1"
  team_name              = "example-team"
  business-unit          = "example-bu"
  application            = "exampleapp"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "example-team@digital.justice.gov.uk"
  namespace              = "test"

  providers = {
    # Can be either 'aws.london' or 'aws.ireland'
    # It requires the two providers to be defined. see example/main.tf
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_team_broker" {
  metadata {
    name      = "example-team-broker-output"
    namespace = "my-namespace"
  }

  data = {
    primary_amqp_ssl_endpoint  = module.example_team_broker.primary_amqp_ssl_endpoint
    primary_stomp_ssl_endpoint = module.example_team_broker.primary_stomp_ssl_endpoint
    username                   = module.example_team_broker.username
    password                   = module.example_team_broker.password
  }
}

