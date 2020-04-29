data "template_file" "consul" {
  template = <<-EOF

%{if var.cloud_provider == "gcp"}
INSTANCE_ID=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
PRIVIP=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
%{endif}

%{if var.cloud_provider == "aws"}
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\")
PRIVIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4/)
%{endif}

tee -a /etc/consul/consul.d/10bind.json << EOJ
{
"advertise_addr": "$PRIVIP",
"advertise_addr_wan": "$PRIVIP",
"bind_addr": "$PRIVIP",
"host_name": "$INSTANCE_ID"
}
EOJ

chown consul:bin /etc/consul/consul.d/10bind.json
chmod 644 /etc/consul/consul.d/10bind.json

systemctl enable consul
systemctl start consul

echo "Waiting for Consul to join..."
until [ $(curl -s http://localhost:8500/v1/health/node/$INSTANCE_ID | jq -r '.[0] | .Status') == "passing" ]
do
  printf '.'
  sleep 5
done

consul services register /home/ubuntu/host-node-exporter-payload.json
consul services register /home/ubuntu/polkadot-client-node-exporter-payload.json

EOF

  vars = {}

}
