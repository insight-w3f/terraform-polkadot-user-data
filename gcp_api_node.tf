data "template_file" "gcp_api_node" {
  template = <<-EOT
mkfs.ext4 -F /dev/nvme0n1
mkdir -p /data
mount /dev/nvme0n1 /data
chmod a+w /data
EOT
}