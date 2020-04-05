data "template_file" "library_node" {
  template = <<-EOT
    systemctl stop polkadot
    mkdir /data/polkadot
    chown polkadot:polkadot /data/polkadot
    mv /home/polkadot/.local/share/polkadot/chains /data/polkadot/
    ln -s /data/polkadot /home/polkadot/.local/share
    systemctl start polkadot
  EOT
}
