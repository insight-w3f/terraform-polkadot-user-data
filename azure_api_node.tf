data "template_file" "azure_api_node" {
  template = <<-EOT
mkfs.ext4 -F /dev/sdc
mkdir -p /mnt/disks/nvme
mount /dev/sdc /mnt/disks/nvme
chmod a+w /mnt/disks/nvme

systemctl stop polkadot
mkdir /mnt/disks/nvme/polkadot
chown polkadot:polkadot /mnt/disks/nvme/polkadot
mv /home/polkadot/.local/share/polkadot/chains /mnt/disks/nvme/polkadot/
ln -s /mnt/disks/nvme/polkadot /home/polkadot/.local/share
systemctl start polkadot
EOT
}