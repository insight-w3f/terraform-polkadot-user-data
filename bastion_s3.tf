
variable "s3_bucket_name" {
  default = ""
}

variable "s3_bucket_uri" {
  default = ""
}

variable "enable_hourly_cron_updates" {
  default = "false"
}

variable "keys_update_frequency" {
  default = ""
}

variable "ssh_user" {
  default = "ubuntu"
}

data "template_file" "bastion_s3" {
  template = <<-EOT
##############
# Install deps
##############

# Apt based distro
if command -v apt-get &>/dev/null; then
  apt-get update
  apt-get install python-pip jq -y

# Yum based distro
elif command -v yum &>/dev/null; then
  yum update -y
  # epel provides python-pip & jq
  yum install -y epel-release
  yum install python-pip jq -y
fi

#####################

pip install --upgrade awscli

##############

cat <<"EOF" > /home/${var.ssh_user}/update_ssh_authorized_keys.sh
#!/usr/bin/env bash

set -e

BUCKET_NAME=${var.s3_bucket_name}
BUCKET_URI=${var.s3_bucket_uri}
SSH_USER=${var.ssh_user}
MARKER="# KEYS_BELOW_WILL_BE_UPDATED_BY_TERRAFORM"
KEYS_FILE=/home/$SSH_USER/.ssh/authorized_keys
TEMP_KEYS_FILE=$(mktemp /tmp/authorized_keys.XXXXXX)
PUB_KEYS_DIR=/home/$SSH_USER/pub_key_files/
PATH=/usr/local/bin:$PATH

[[ -z $BUCKET_URI ]] && BUCKET_URI="s3://$BUCKET_NAME/"

mkdir -p $PUB_KEYS_DIR

# Add marker, if not present, and copy static content.
grep -Fxq "$MARKER" $KEYS_FILE || echo -e "\n$MARKER" >> $KEYS_FILE
line=$(grep -n "$MARKER" $KEYS_FILE | cut -d ":" -f 1)
head -n $line $KEYS_FILE > $TEMP_KEYS_FILE

# Synchronize the keys from the bucket.
aws s3 sync --delete --exact-timestamps $BUCKET_URI $PUB_KEYS_DIR
for filename in $PUB_KEYS_DIR/*; do
    [ -f "$filename" ] || continue
    sed 's/\n\?$/\n/' < $filename >> $TEMP_KEYS_FILE
done

# Move the new authorized keys in place.
chown $SSH_USER:$SSH_USER $KEYS_FILE
chmod 600 $KEYS_FILE
mv $TEMP_KEYS_FILE $KEYS_FILE
if [[ $(command -v "selinuxenabled") ]]; then
    restorecon -R -v $KEYS_FILE
fi
EOF

cat <<"EOF" > /home/${var.ssh_user}/.ssh/config
Host *
    StrictHostKeyChecking no
EOF
chmod 600 /home/${var.ssh_user}/.ssh/config
chown ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/.ssh/config

chown ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/update_ssh_authorized_keys.sh
chmod 755 /home/${var.ssh_user}/update_ssh_authorized_keys.sh

# Execute now
su ${var.ssh_user} -c /home/${var.ssh_user}/update_ssh_authorized_keys.sh

# Be backwards compatible with old cron update enabler
if [ "${var.enable_hourly_cron_updates}" = 'true' -a -z "${var.keys_update_frequency}" ]; then
  keys_update_frequency="0 * * * *"
else
  keys_update_frequency="${var.keys_update_frequency}"
fi

# Add to cron
if [ -n "$keys_update_frequency" ]; then
  croncmd="/home/${var.ssh_user}/update_ssh_authorized_keys.sh"
  cronjob="$keys_update_frequency $croncmd"
  ( crontab -u ${var.ssh_user} -l | grep -v "$croncmd" ; echo "$cronjob" ) | crontab -u ${var.ssh_user} -
fi
EOT
  //  vars = {
  //    s3_bucket_name = var.s3_bucket_name
  //    s3_bucket_uri = var.s3_bucket_uri
  //    ssh_user = var.ssh_user
  //    enable_hourly_cron_updates = var.enable_hourly_cron_updates
  //    keys_update_frequency = var.keys_update_frequency
  //  }
}


