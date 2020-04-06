data "template_file" "consul" {
  template = <<-EOF
apt install -y zip
curl --silent --remote-name https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
unzip consul_1.6.1_linux_amd64.zip
chown root:root consul
mv consul /usr/local/bin/
useradd --system --home /etc/consul.d --shell /bin/false consul
mkdir --parents /opt/consul
chown --recursive consul:consul /opt/consul
PRIVIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4/)

tee -a /etc/systemd/system/consul.service << CONSULSVCEND
[Unit]
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-file=/etc/consul.d/consul.hcl -retry-join="provider=aws tag_key=consul-servers tag_value=auto-join addr_type=private_v4"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5
Restart=on-failure
SyslogIdentifier=consul

[Install]
WantedBy=multi-user.target
CONSULSVCEND

mkdir --parents /etc/consul.d
tee -a /etc/consul.d/consul.hcl << CONSULHCLEND
{
"bind_addr": "$PRIVIP",
"datacenter": "${var.region}",
"data_dir": "/opt/consul",
"server": false
"retry_join": ["provider=aws tag_key=consul-servers tag_value=auto-join addr_type=private_v4"]
}
CONSULHCLEND

chown --recursive consul:consul /etc/consul.d
chmod 640 /etc/consul.d/consul.hcl

systemctl enable consul
systemctl start consul

consul services register /home/ubuntu/host-node-exporter-payload.json
consul services register /home/ubuntu/docker-node-exporter-payload.json

EOF

  vars = {}

}
