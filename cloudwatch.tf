
variable "log_config_bucket" {
  default = ""
}

variable "log_config_key" {
  default = ""
}

data "template_file" "cloudwatch" {
  template = <<-EOT
############
# Cloudwatch
############
curl https://s3.amazonaws.com//aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
chmod +x ./awslogs-agent-setup.py
/awslogs-agent-setup.py -n -r us-east-1 -c s3://${var.log_config_bucket}/${var.log_config_key}.
EOT
}
