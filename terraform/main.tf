provider "aws" {
  # No credentials explicitly set here because they come from either the
  # environment or the global credentials file.
  region = "ap-northeast-1"
}
terraform {
  backend "s3" {
    region               = "ap-northeast-1"
    # state be stored to {bucket}/{workspace_key_prefix}/{terraform.workspace}/{key}
    bucket               = "deploy-047980477351-ap-northeast-1-efg.river"
    workspace_key_prefix = "portfolio-2020"

    key = "components/portfolio-2020-tasks/terraform.tfstate"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"

  name = "portofolio-vpc-${terraform.workspace}"

  cidr                = "10.0.0.0/16"
  azs                 = ["ap-northeast-1a"]
  private_subnets     = []
  public_subnets      = ["10.0.11.0/24"]

  create_database_subnet_route_table    = false
  create_elasticache_subnet_route_table = false
  enable_nat_gateway = false
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/ecs/portfolio-2020-task-cluster-${terraform.workspace}"
}

resource "aws_ecs_cluster" "task_cluster" {
  name = "portofolio-2020-task-cluster-${terraform.workspace}"
}

locals {
  # Common tags to be assigned to all resources
  default_attributes = {
    cluster_arn = aws_ecs_cluster.task_cluster.arn
    subnets = module.vpc.public_subnets
    awslogs_group = aws_cloudwatch_log_group.log_group.name
    image_repository_url = "efgriver/ex-awsconf"
    image_tag = "latest"
    cpu_units = 256 # see Task CPU and Memory https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html 
    memory_mib = 1024 # see Task CPU and Memory https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
    is_enabled = true # please set false only-if expected to stop the task in temporary. 
    cost_tag_env = terraform.workspace
    firebase_function_url = ""
    fargate_platform_version = "1.3.0" # FARGATE platform version https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform_versions.html
  } 
}

# サンプル 
module "test" {
  source = "./modules/scheduled-task" 
  attributes = merge(local.default_attributes, {
    task_name = "test", # task name
    schedule_expression = "cron(0/15 * * * ? *)", # https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/events/ScheduledEvents.html
    task_command = [ "ls -la" ], # https://docs.docker.com/engine/reference/builder/#cmd
    is_enabled = true
  })
}
