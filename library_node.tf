data "template_file" "library_node" {
  template = <<-EOT
    systemctl stop polkadot
    mkdir -p /data/polkadot
    chown polkadot:polkadot /data/polkadot
    if [[ -d /home/polkadot/.local/share/polkadot/chains ]]
    then
      mv /home/polkadot/.local/share/polkadot/chains /data/polkadot/
    else
      mkdir -p /home/polkadot/.local/share/
    ln -s /data/polkadot /home/polkadot/.local/share
    systemctl start polkadot
  EOT
}
