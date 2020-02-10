data "template_file" "prometheus_consul" {
  template = <<-EOF
## Prometheus setup
# Set node exporter version
# Either pin to latest
#NODE_EXPORTER_VERSION='latest'
# Or pin a specific release
# NOTE: "latest" doensn't seem to work :/
NODE_EXPORTER_VERSION='0.18.1'

useradd -m -s /bin/bash prometheus

curl -L -O  https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

tar -xzvf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64 /home/prometheus/node_exporter
rm node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
chown -R prometheus:prometheus /home/prometheus/node_exporter

# Add node_exporter as systemd service
tee -a /etc/systemd/system/node_exporter.service << NODEEXPEND
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
ExecStart=/home/prometheus/node_exporter/node_exporter
[Install]
WantedBy=default.target
NODEEXPEND

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

EC2_INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\")
PRIVIP=$(wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4 || die \"wget local-ipv4 has failed: $?\")

tee -a /home/ubuntu/host-node-exporter-payload.json << HOSTPAYLOADEND
{
  "service": {
    "ID": "host_$EC2_INSTANCE_ID",
    "Name": "consul_node_exporter",
    "Tags": ["${var.node_tags}"],
    "Address": "$PRIVIP",
    "Port": 9100,
    "Check": {
      "DeregisterCriticalServiceAfter": "60m",
      "id": "prometheus-api",
      "name": "HTTP on port 9100",
      "http": "http://$PRIVIP:9100",
      "interval": "10s",
      "timeout": "1s"
    }
  }
}
HOSTPAYLOADEND

tee -a /home/ubuntu/docker-node-exporter-payload.json << DOCKERPAYLOADEND
{
  "service": {
    "ID": "docker_$EC2_INSTANCE_ID",
    "Name": "consul_node_exporter",
    "Tags": ["${var.node_tags}"],
    "Address": "$PRIVIP",
    "Port": 9323,
    "Check": {
      "DeregisterCriticalServiceAfter": "60m",
      "id": "prometheus-api",
      "name": "HTTP on port 9323",
      "http": "http://$PRIVIP:9323/metrics",
      "interval": "10s",
      "timeout": "1s"
    }
  }
}
DOCKERPAYLOADEND

EOF
  vars     = {}
}