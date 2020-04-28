data "template_file" "consul" {
  template = <<-EOF

%{if var.cloud_provider == "gcp"}
PRIVIP=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
%{endif}

%{if var.cloud_provider == "aws"}
PRIVIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4/)
%{endif}

tee -a /etc/consul/consul.d/10bind.json << EOJ
{
"advertise_addr": "$PRIVIP",
"advertise_addr_wan": "$PRIVIP",
"bind_addr": "$PRIVIP"
}
EOJ

chown consul:bin /etc/consul/consul.d/10bind.json
chmod 644 /etc/consul/consul.d/10bind.json

systemctl enable consul
systemctl start consul

consul services register /home/ubuntu/host-node-exporter-payload.json
consul services register /home/ubuntu/docker-node-exporter-payload.json

EOF

  vars = {}

}
