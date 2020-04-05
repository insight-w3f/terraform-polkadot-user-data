data "aws_region" "this" {}

locals {
  ebs_attachment = contains(["sentry", "validator"], var.type) && var.mount_volumes
}

data "template_file" "disable_ipv6" {
  template = <<-EOF
sudo sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT="maybe-ubiquity"/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 maybe-ubiquity"/' /etc/default/grub
sudo sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
sudo update-grub
EOF
}

data "template_file" "nitro_ebs" {
  template = <<-EOF
apt-get upgrade -y linux-aws
file -s /dev/nvme1n1
mkdir /data
chown -R ubuntu:ubuntu /data
mkfs -t xfs /dev/nvme1n1
mount /dev/nvme1n1 /data
EOF
}

data "template_file" "standard_ebs" {
  template = <<-EOF
mkdir /data
chown -R ubuntu:ubuntu /data/
mkfs.ext4 /dev/xvdf
mount /dev/xvdf /data
EOF
}


data "template_file" "user_data" {
  template = <<-EOF
#!/usr/bin/env bash
${var.provider == "azure" && var.type == "library" ? data.template_file.azure_api_node.rendered : ""}
${var.provider == "gcp" && var.type == "library" ? data.template_file.gcp_api_node.rendered : ""}
${var.disable_ipv6 ? data.template_file.disable_ipv6.rendered : ""}
${var.consul_enabled ? data.template_file.consul.rendered : ""}
${var.consul_enabled && var.prometheus_enabled ? data.template_file.prometheus_consul.rendered : ""}
${var.driver_type == "nitro" && local.ebs_attachment ? data.template_file.nitro_ebs.rendered : ""}
${var.driver_type == "standard" && local.ebs_attachment ? data.template_file.standard_ebs.rendered : ""}
${var.type == "validator" ? data.template_file.validator.rendered : ""}
${var.type == "sentry" ? data.template_file.sentry.rendered : ""}
${var.type == "bastion_s3" ? data.template_file.bastion_s3.rendered : ""}
EOF

  vars = {}
}

