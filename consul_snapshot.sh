#!/bin/bash

set -e

# Variables

consul_version="1.4.3"
consul_path="/etc/consul"
os_type="linux_amd64"
os="mac"
nic=$(ip route show default | awk '/default/ {print $5}')
node_name=$(hostnamectl --static)

# Step 1

echo "# Ensure all pre requisites are met"
echo "-----------------------------------"

sudo apt-get install -y jq unzip  

echo "# Downloading Consul Binaries from Hashicorp Releases website"
echo "-------------------------------------------------------------"

curl -o ~/consul-${consul_version}.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_${os_type}.zip

echo "# Unzip Consul package, apply appropriate permissions and move binary to correct directory"
echo "------------------------------------------------------------------------------------------"

unzip ~/consul-${consul_version}.zip
sudo chown root:root consul
if [ ${os} == "redhat" ]
    then 
    sudo mv consul /usr/local/sbin
    else 
    sudo mv consul /usr/local/bin
fi

sudo rm ~/consul-${consul_version}.zip

echo "# Create Consul User and Directories"
echo "-----------------------------------------"

# Create Consul User 
sudo useradd -r -d ${consul_path} -s /bin/false consul

# Configuration Dir
sudo mkdir -p ${consul_path}/consul.d
sudo chown -R consul:consul /etc/consul
# Logs Dir
sudo mkdir -p /var/log/consul
# Run Dir
sudo mkdir -p /var/run/consul
sudo chown -R consul:consul /var/run/consul
# Consul Data Dir
sudo mkdir -p /var/consul
sudo chown -R consul:consul /var/consul

echo "# Create Consul Configuration File"
echo "----------------------------------"

# Generate Consul Gossip Encryption Key
# consul_gossip_token=$(consul keygen)

# Retrieve IP Address on Default Nic on the Host
ip_address=$(ifconfig ${nic} | awk '/inet addr/{print substr($2, 6)}')

# Generate Consul Configuration file
sudo tee /etc/consul/config.json > /dev/null <<EOF
{
    "datacenter": "nicodc",
    "node_name": "${node_name}",
    "data_dir": "/var/consul/",
    "addresses": {
        "http": "${ip_address}", 
        "dns": "${ip_address}"
    },
    "advertise_addr": "${ip_address}",
    "autopilot": {
        "cleanup_dead_servers": true,
        "last_contact_threshold": "200ms",
        "max_trailing_logs": 250,
        "server_stabilization_time": "10s"
    },
    "bootstrap_expect": 3,
    "bind_addr": "${ip_address}",
    "connect": {
        "enabled": true
    },
    "encrypt": "k4Enbq2cpFcgs9/VGCmrjw==",
    "enable_local_script_checks": true,
    "leave_on_terminate": true,
    "log_level": "INFO",
    "ports": {
        "http": 8500
    },
    "retry_join": ["192.168.94.139","192.168.94.138","192.168.94.137"]
    "server": true,
    "ui": true
}
EOF

echo "# Create Consul Service Configuration with systemd"
echo "--------------------------------------------------"

sudo tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
PIDFile=/var/run/consul/consul.pid
PermissionsStartOnly=true
ExecStart=/usr/local/bin/consul agent -config-file=/etc/consul/config.json -config-dir=/etc/consul/consul.d -pid-file=/var/run/consul/co$
ExecReload=/usr/local/bin/consul reload
KillMode=process
KillSignal=SIGTERM
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
