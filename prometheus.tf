data "template_file" "prometheus_consul" {
  template = <<-EOF
%{if var.cloud_provider == "gcp"}
INSTANCE_ID=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
PRIVIP=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
%{endif}

%{if var.cloud_provider == "aws"}
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\")
PRIVIP=$(wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4 || die \"wget local-ipv4 has failed: $?\")
%{endif}

tee -a /home/ubuntu/host-node-exporter-payload.json << HOSTPAYLOADEND
{
  "service": {
    "ID": "host_$INSTANCE_ID",
    "Name": "consul_node_exporter",
    "Tags": ["${var.node_tags}"],
    "Address": "$PRIVIP",
    "Port": 9101,
    "Check": {
      "DeregisterCriticalServiceAfter": "60m",
      "id": "host-prometheus",
      "name": "HTTP on port 9100",
      "http": "http://$PRIVIP:9100",
      "header": {"Authorization": ["Basic base64encode(${var.prometheus_user}:${var.prometheus_password})"]},
      "interval": "10s",
      "timeout": "1s"
    }
  }
}
HOSTPAYLOADEND

tee -a /home/ubuntu/polkadot-client-node-exporter-payload.json << CLIENTPAYLOADEND
{
  "service": {
    "ID": "polkadot_$INSTANCE_ID",
    "Name": "consul_node_exporter",
    "Tags": ["${var.node_tags}"],
    "Address": "$PRIVIP",
    "Port": 9615,
    "Check": {
      "DeregisterCriticalServiceAfter": "60m",
      "id": "polkadot-client-prometheus",
      "name": "HTTP on port 9615",
      "http": "http://$PRIVIP:9615/metrics",
      "header": {"Authorization": "Basic base64encode(${var.prometheus_user}:${var.prometheus_password})"},
      "interval": "10s",
      "timeout": "1s"
    }
  }
}
CLIENTPAYLOADEND

EOF
  vars     = {}
}