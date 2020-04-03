data "template_file" "library_node" {
  template = <<-EOT
    systemctl stop polkadot
    mkdir /mnt/disks/nvme/polkadot
    chown polkadot:polkadot /mnt/disks/nvme/polkadot
    mv /home/polkadot/.local/share/polkadot/chains /mnt/disks/nvme/polkadot/
    ln -s /mnt/disks/nvme/polkadot /home/polkadot/.local/share
    systemctl start polkadot
  EOT
}
