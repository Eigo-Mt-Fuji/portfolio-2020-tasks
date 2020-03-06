## AWS CloudWatch Event Rule limit https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/cloudwatch_limits_cwe.html
## Rules 100 per region per account
resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "cloudwatch_event_rule-${var.attributes.task_name}-${terraform.workspace}"
  description         = "cloudwatch_event_rule-${var.attributes.task_name}-${terraform.workspace}"
  schedule_expression = "${var.attributes.schedule_expression}"
  is_enabled = var.attributes.is_enabled # https://www.terraform.io/docs/providers/aws/r/cloudwatch_event_rule.html#is_enabled
}

resource "aws_cloudwatch_event_target" "event_target" {
  arn       = "${var.attributes.cluster_arn}" # ecs cluster arn
  rule      = "${aws_cloudwatch_event_rule.event_rule.name}" # cloud watch event rule
  role_arn  = "${aws_iam_role.ecs_event.arn}" # IAM role for allowing cloud watch event to run ECS task

  # see ecs_target https://www.terraform.io/docs/providers/aws/r/cloudwatch_event_target.html
  ecs_target {
    task_definition_arn = aws_ecs_task_definition.task.arn
    task_count = 1 

    launch_type = "FARGATE"
    platform_version = "${var.attributes.fargate_platform_version}" # used only if LaunchType is FARGATE https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform_versions.html
    
    network_configuration {
        subnets = var.attributes.private_subnets
        assign_public_ip = false
    }
  }
}

# Amazon ECS limits https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/service_limits.html
## アカウント別のリージョンごとに、Fargate 起動タイプを使用するタスクの数	50
## リージョンあたり、アカウントあたりのクラスターの数	2000
resource "aws_ecs_task_definition" "task" {
  family                = "${var.attributes.task_name}-${terraform.workspace}" # A unique name for your task definition  

  # workaround for templatefile function's list variable usage issue
  # https://github.com/terraform-providers/terraform-provider-template/issues/40
  container_definitions = <<EOF
  [
    {
      "name": "${var.attributes.task_name}",
      "image": "${var.attributes.image_repository_url}:${var.attributes.image_tag}",
      "essential": true,
      "memoryReservation": 256,
      "command": ["${join("\",\"", var.attributes.task_command)}"],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-region": "ap-northeast-1",
              "awslogs-group": "${var.attributes.awslogs_group}",
              "awslogs-stream-prefix":"tasks"
          }
      },
      "environment":[
        {
          "name": "FIREBASE_FUNCTION_URL",
          "value": var.attributes.firebase_function_url
        }
      ]
    } 
  ]
  EOF

  task_role_arn = aws_iam_role.task_role.arn # ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services
  execution_role_arn = aws_iam_role.execution_role.arn # ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume.  
  network_mode = "awsvpc"
  requires_compatibilities = [ "FARGATE" ] 
  cpu = var.attributes.cpu_units # optional: number of cpu units used by the task. this field is required for FARGATE
  memory = var.attributes.memory_mib # optional: amount (in MiB) of memory used by the task. this field is required for FARGATE
}

resource "aws_iam_role" "ecs_event" {
  name = "ecs_event_role-${var.attributes.task_name}-${terraform.workspace}"

  assume_role_policy = templatefile("${path.module}/templates/ecs-event-assume-role-policy.json", {})
}

resource "aws_iam_role_policy" "ecs_event_policy" {
  name = "ecs_event_role_policy-${var.attributes.task_name}-${terraform.workspace}"
  role = "${aws_iam_role.ecs_event.id}"

  policy = templatefile("${path.module}/templates/ecs-event-run-task-policy.json", {})
}

# IAM for ECS ExecutionRole https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html

resource "aws_iam_role" "execution_role" {
  name = "execution_role-${var.attributes.task_name}-${terraform.workspace}"

  assume_role_policy = templatefile("${path.module}/templates/ecs-execution-role-assume-role-policy.json", {})
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role = "${aws_iam_role.execution_role.name}"

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "execution_role_ssm_readonly_policy" {
  role = "${aws_iam_role.execution_role.name}"

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}


# IAM for ECS TaskRole https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_IAM_role.html

resource "aws_iam_role" "task_role" {
  name = "task_role-${var.attributes.task_name}-${terraform.workspace}"

  assume_role_policy = templatefile("${path.module}/templates/ecs-task-role-assume-role-policy.json", {})
}

resource "aws_iam_role_policy" "task_role_policy" {
  name = "task_role_policy-${var.attributes.task_name}-${terraform.workspace}"
  role = "${aws_iam_role.task_role.id}"

  policy = templatefile("${path.module}/templates/ecs-task-role-policy.json", {})
}
