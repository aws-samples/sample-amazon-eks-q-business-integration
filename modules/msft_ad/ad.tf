data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "random_string" "secret_name" {
  length  = 4
  upper   = false
  numeric = true
  lower   = true
  special = false
}

locals {
  secret_name = "${var.domain-admin-credentials-secret-name}-${random_string.secret_name.result}"
}

data "aws_subnets" "private" {
   filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    subnet-type = "private"
  }
  depends_on = [var.vpc_id]
}

data "aws_subnets" "public" {
   filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    subnet-type = "public"
  }
depends_on = [var.vpc_id]
}

resource "random_password" "domain_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  upper            = true
  lower            = true
  numeric          = true
}

resource "aws_secretsmanager_secret" "domain_admin_credentials" {
name = local.secret_name
}

resource "aws_secretsmanager_secret_version" "domain_admin_credentials" {
  secret_id     = aws_secretsmanager_secret.domain_admin_credentials.id
  secret_string = jsonencode({
    password = random_password.domain_admin_password.result
  })
  depends_on = [aws_secretsmanager_secret.domain_admin_credentials]
}
/*
data "aws_secretsmanager_secret_version" "ad_admin_password" {
  secret_id = aws_secretsmanager_secret.domain_admin_credentials.id
}
*/
resource "aws_directory_service_directory" "ad_directory" {
  name     = var.name
  #password = data.aws.aws_secretsmanager_secret_version.domain_admin_credentials_version.secret_string
  password = aws_secretsmanager_secret_version.domain_admin_credentials.secret_string
  #password = data.aws_secretsmanager_secret_version.ad_admin_password.secret_string
  edition  = "Enterprise"
  type     = "MicrosoftAD"
#  desired_number_of_domain_controllers = 3

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = [data.aws_subnets.private.ids[0], data.aws_subnets.private.ids[1]]
    #subnet_ids = tolist(sort(data.aws_subnets.private.ids))
  }
   depends_on = [aws_secretsmanager_secret_version.domain_admin_credentials]
}

resource "null_resource" "wait_for_directory_creation" {
  depends_on = [aws_directory_service_directory.ad_directory]

  provisioner "local-exec" {
    command = <<-EOT
      while true; do
        status=$(aws ds describe-directories --directory-id ${aws_directory_service_directory.ad_directory.id} --query 'DirectoryDescriptions[0].Stage' --output text)
        if [ "$status" == "Active" ]; then
          break
        else
          echo "Directory not ready yet, waiting..."
          sleep 10
        fi
      done
    EOT
  }

  provisioner "local-exec" {
    command = "aws ds enable-directory-data-access --directory-id ${aws_directory_service_directory.ad_directory.id}"
  }
}
