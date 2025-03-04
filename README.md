# aws2tf

**Work in progress - please report any issues you find.**

This utility 'AWS to Terraform' (aws2tf)
reads an AWS Account and generates all the required terraform configuration files (.tf) from each of the composite AWS resources

It also imports the terraform state using a

"terraform import ...." command

And finally runs a

"terraform plan"  command

There should hopefully be no subsequent additions or deletions reported by the terraform plan command as all the appropriate terraform configuration files will have have automatically been created.

## Requirements & Prerequisites
+ The tool is written for the bash shell script & Python3 and has been tested on macOS 11.6.
+ AWS cli (v2) **version 2.3.4 or higher** needs to be installed and you need a login with at least "Read" privileges.
+ terraform **version v1.1.0** or higher needs to be installed.
+ jq **version 1.6 or higher**


## Quickstart guide to using the tool

Running the tool in your local shell (bash) required these steps:
1. Unzip or clone this git repo into an empty directory
2. login to the AWS cli  (aws configure)
3. run the tool


## Usage Guide

### The First Run
To generate the terraform files for an account and stop after a "terraform validate":
```
./aws2tf.sh -v yes
```

or if your interested in a type or group for example: Transit Gateway resources:
```
./aws2tf.sh -v yes -t tgw
```

```
terraform validate
Success! The configuration is valid.
```


Or there may be some kind of error as trying to test everyone's AWS combinations in advance isn't possible.

**If you happen to find one of these errors please open an issue here and paste in the error and it will get fixed.**


Once the validation is ok you can remove the -v which then also runs the `terraform plan`.

---

<br>

To generate the terraform files for an entire AWS account, import the resources and perform a terraform plan:
```
./aws2tf.sh 
```


To include AWS account Policies and Roles:
```
./aws2tf.sh -p yes
```

To generate the terraform files for an EKS cluster named "mycluster"
```
./aws2tf.sh -t eks -i mycluster
```

To add App Mesh resources

```
./aws2tf.sh -t appmesh -c yes
```

----


To get a selection of resources use the -t option 
The currently supported types are:

* appmesh - App Mesh resources `-t appmesh`
* code - Code* resources `-t code`
* cognito - Cognito resources `-t cognito`
* config - AWS config resources `-t config`
* eb - EventBridge resources `-t eb`
* ecs - An ECS cluster and it's related resources `-t ecs -i Cluster-Name`
* eks - An EKS cluster and it's related resources `-t eks -i Cluster-Name`
* emr - get all active EMR clusters
* iam - All IAM related users, groups, policies & roles `-t iam`
* kms - KMS keys and aliases `-t kms`
* lf - Lake Formation resources `-t lf`
* lambda - Lambda resources `-t lambda`
* params - SSM parameters `-t params`
* org - AWS Organizations `-t org`
* rds - RDS database resources `-t rds`
* secrets - Secrets Manager secrets `-t secrets`
* sagemaker - SageMaker resources `-t sagemaker`
* sc - Service Catalog resources `-t sc`
* sns - SNS resources `-t sns`
* sqs - SQS queues `-t sqs`
* spot - spot requests `-t spot`
* tgw - Transit Gateway resources `-t tgw <-i transit-gateway-id>`
* vpc - A VPC and it's related resources `-t vpc <-i VPC-id>`
  

To get all the VPC related resources in a particular VPC
```
./aws2tf.sh -t vpc -i vpc-xxxxxxxxx
```
To use a specific region and profile
```
./aws2tf.sh -t vpc -i vpc-xxxxxxxxx -r eu-west-1 -p default
```

#### Using the cumulative mode

If for example you want to get several VPCs you can use the cumulative mode:

To get all the VPC related resources in a particular VPC
```
./aws2tf.sh -t vpc -i vpc-aaaaaaaaa 
./aws2tf.sh -t vpc -i vpc-bbbbbbbbb -c yes
./aws2tf.sh -t vpc -i vpc-ccccccccc -c yes
```

<br>

Be patient - lots of output is given as aws2tf:

+ Loops through each provider 
+ Creates the requited *.tf configuration files in the "generated" directory
+ Performs the necessary 'terraform import' commands
+ And finally runs a 'terraform plan'

----

###  Experimental - still under development

To get all the resources in a deployed Stack Set

```
./aws2tf.sh -s <stack set name>
```

*Please open an issue for any resources you see in the `unprocessed.log` to help prioritize development*

Or simply check back after some time to see if they are listed below.


----
## Terraform resources supported as of 05-Mar-2022

* aws_appmesh_gateway_route
* aws_appmesh_mesh
* aws_appmesh_route
* aws_appmesh_virtual_gateway
* aws_appmesh_virtual_node
* aws_appmesh_virtual_router
* aws_appmesh_virtual_service
* aws_autoscaling_group
* aws_cloud9_environment_ec2
* aws_cloudformation_stack
* aws_cloudfront_distribution
* aws_cloudtrail
* aws_cloudwatch_event_bus
* aws_cloudwatch_event_rule
* aws_cloudwatch_event_target
* aws_cloudwatch_log_group
* aws_codeartifact_domain
* aws_codeartifact_repository
* aws_codebuild_project
* aws_codepipeline
* aws_cognito_identity_pool
* aws_cognito_identity_pool_roles_attachment
* aws_cognito_user_pool
* aws_cognito_user_pool_client
* aws_config_config_rule
* aws_config_configuration_recorder
* aws_config_configuration_recorder_status
* aws_config_delivery_channel
* aws_customer_gateway
* aws_db_instance
* aws_db_subnet_group
* aws_directory_service_directory
* aws_dms_endpoint
* aws_dms_replication_instance
* aws_dms_replication_task
* aws_dynamodb_table
* aws_ec2_client_vpn_endpoint
* aws_ec2_transit_gateway
* aws_ec2_transit_gateway_route
* aws_ec2_transit_gateway_route_table
* aws_ec2_transit_gateway_vpc_attachment
* aws_ec2_transit_gateway_vpn_attachment
* aws_ecr_repository
* aws_ecs_cluster
* aws_ecs_service
* aws_ecs_task_definition
* aws_eip
* aws_eks_cluster
* aws_eks_fargate_profile
* aws_eks_node_group
* aws_emr_cluster
* aws_emr_instance_group
* aws_emr_managed_scaling_policy
* aws_emr_security_configuration
* aws_glue_catalog_database
* aws_glue_catalog_table
* aws_glue_crawler
* aws_glue_partition
* aws_iam_group
* aws_iam_instance_profile
* aws_iam_policy
* aws_iam_role
* aws_iam_role_policy
* aws_iam_role_policy_attachment
* aws_iam_user
* aws_iam_user_group_membership
* aws_instance
* aws_internet_gateway
* aws_kinesis_firehose_delivery_stream
* aws_kinesis_stream
* aws_kms_alias
* aws_kms_key
* aws_lakeformation_resource
* aws_lambda_alias
* aws_lambda_function
* aws_lambda_function_event_invoke_config
* aws_lambda_permission
* aws_launch_template
* aws_lb
* aws_lb_listener
* aws_lb_listener_rule
* aws_lb_target_group
* aws_nat_gateway
* aws_network_interface
* aws_organizations_account
* aws_organizations_organization
* aws_organizations_organizational_unit
* aws_organizations_policy
* aws_organizations_policy_attachment
* aws_route53_zone
* aws_route_table
* aws_route_table_association
* aws_s3_access_point
* aws_s3_bucket
* aws_s3_bucket_policy
* aws_sagemaker_app
* aws_sagemaker_app_image_config
* aws_sagemaker_domain
* aws_sagemaker_image
* aws_sagemaker_image_version
* aws_sagemaker_user_profile
* aws_secretsmanager_secret
* aws_secretsmanager_secret_version
* aws_security_group
* aws_security_group_rule
* aws_service_discovery_private_dns_namespace
* aws_service_discovery_service
* aws_servicecatalog_constraint
* aws_servicecatalog_portfolio
* aws_servicecatalog_principal_portfolio_association
* aws_servicecatalog_product
* aws_servicecatalog_product_portfolio_association
* aws_sns_topic
* aws_sns_topic_subscription
* aws_spot_fleet_request
* aws_sqs_queue
* aws_ssm_association
* aws_ssm_document
* aws_ssm_parameter
* aws_ssoadmin_managed_policy_attachment
* aws_ssoadmin_permission_set
* aws_ssoadmin_permission_set_inline_policy
* aws_subnet
* aws_vpc
* aws_vpc_dhcp_options
* aws_vpc_endpoint
* aws_vpc_endpoint_service
* aws_vpc_ipv4_cidr_block_association
* aws_vpc_peering_connection
* aws_vpn_connection

----
## Resources within a Stack Set that can currently be converted to Terraform (-s <stack set name>) as of 05-Mar-2022

* AWS::Cloud9::EnvironmentEC2
* AWS::CodeArtifact::Domain
* AWS::CodeArtifact::Repository
* AWS::Cognito::IdentityPool
* AWS::Cognito::IdentityPoolRoleAttachment
* AWS::Cognito::UserPool
* AWS::Cognito::UserPoolClient
* AWS::DynamoDB::Table
* AWS::EC2::EIP
* AWS::EC2::Instance
* AWS::EC2::InternetGateway
* AWS::EC2::LaunchTemplate
* AWS::EC2::NatGateway
* AWS::EC2::NetworkAcl
* AWS::EC2::NetworkAclEntry
* AWS::EC2::Route
* AWS::EC2::RouteTable
* AWS::EC2::SecurityGroup
* AWS::EC2::SecurityGroupIngress
* AWS::EC2::Subnet
* AWS::EC2::SubnetNetworkAclAssociation
* AWS::EC2::SubnetRouteTableAssociation
* AWS::EC2::VPC
* AWS::EC2::VPCEndpoint
* AWS::EC2::VPCGatewayAttachment
* AWS::ECR::Repository
* AWS::ECS::Cluster
* AWS::ECS::Service
* AWS::ECS::TaskDefinition
* AWS::EKS::Cluster
* AWS::EKS::Nodegroup
* AWS::ElasticLoadBalancingV2::Listener
* AWS::ElasticLoadBalancingV2::ListenerRule
* AWS::ElasticLoadBalancingV2::LoadBalancer
* AWS::ElasticLoadBalancingV2::TargetGroup
* AWS::Events::EventBus
* AWS::Events::Rule
* AWS::Glue::Database
* AWS::Glue::Partition
* AWS::Glue::Table
* AWS::IAM::AccessKey
* AWS::IAM::InstanceProfile
* AWS::IAM::ManagedPolicy
* AWS::IAM::Policy
* AWS::IAM::Role
* AWS::IAM::User
* AWS::KMS::Alias
* AWS::KMS::Key
* AWS::KinesisFirehose::DeliveryStream
* AWS::Lambda::EventInvokeConfig
* AWS::Lambda::Function
* AWS::Lambda::Permission
* AWS::Logs::LogGroup
* AWS::S3::Bucket
* AWS::SNS::Topic
* AWS::SNS::TopicPolicy
* AWS::SQS::Queue
* AWS::SSM::Parameter
* AWS::SageMaker::AppImageConfig
* AWS::SageMaker::Domain
* AWS::SageMaker::Image
* AWS::SageMaker::ImageVersion
* AWS::SecretsManager::Secret
* AWS::ServiceDiscovery::Service
 
----


+ Other terraform providers as terraform supports.

----

## Known problems

### Speed

It can take a lot of time to loop around everything in large accounts, in particular the importing of the resources.

### KMS:

Can fail if your login doesn't have access to KMS

### S3 Buckets

Can fail if you don't have access to the KMS key used for encryption.






