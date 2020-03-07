variable "attributes" {
    type = object({ 
        cluster_arn = string,
        subnets = list(string),
        awslogs_group = string,
        image_repository_url = string,
        image_tag = string,
        cpu_units = number,
        memory_mib = number,
        is_enabled = bool,
        fargate_platform_version = string,
        firebase_function_url = string,
        task_name = string,
        task_command = list(string),
        schedule_expression = string
    })
    
    default = {
        task_name = ""
        task_command = [ "" ]
        schedule_expression = "cron(0/15 * * * ? *)"
        cluster_arn = ""
        subnets = []
        awslogs_group = ""
        image_repository_url = ""
        image_tag = "latest"
        cpu_units = 256
        memory_mib = 1024
        is_enabled = true
        firebase_function_url = ""
        fargate_platform_version = "1.3.0" # FARGATE platform version https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform_versions.html
    }
}
