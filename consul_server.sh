#!/bin/bash

###########################################################################################
# How to use this script :                                                                #
#   ./consul_server.sh consul_version os_type os license encryption_key consul_acl_token  #
#                                                                                         #
# consul_version :                                                                        #
#   - OSS : 1.4.3                                                                         #
#   - Ent: 1.4.3+ent (Default)                                                            #
# os_type :                                                                               #
#   - linux_386 or linux_amd64 (Default)                                                  #
#   - linux_arm or linux_arm64                                                            #
#   - freebsd_386 or freebsd_amd64                                                        #
#   - darwin_386 or darwin_amd64                                                          #
#   - solaris_amd64                                                                       #
# os :                                                                                    #
#   - redhat                                                                              #
#   - centos                                                                              #
#   - ubuntu (Default)                                                                    #
#   - solaris                                                                             #
#   - freebsd                                                                             #
#   - macosx                                                                              #
# license : Enterthe license number that Hashicorp provides                               #
# encryption_key : The key must be 16-Bits, base64 encoded.                               #                                          
# consul_acl_token : Like Encryption Key, must be 16-Bits, base64 encoded.                #
###########################################################################################

# Variables

consul_version=${1:-'1.4.3+ent'}
consul_path="/etc/consul"
os_type=${2:-'linux_amd64'}
os=${3:-'ubuntu'}
nic=$(ip route show default | awk '/default/ {print $5}')
node_name=$(hostnamectl --static)
license=${4}
encryption_key=${5}
consul_acl_token=${6}
bootstrap=3

# Prepare the environment and download Consul

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

echo "# Create Consul Server Configuration File"
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
        "http": "0.0.0.0", 
        "dns": "0.0.0.0"
    },
    "advertise_addr": "${ip_address}",
    "autopilot": {
        "cleanup_dead_servers": true,
        "last_contact_threshold": "200ms",
        "max_trailing_logs": 250,
        "server_stabilization_time": "10s"
    },
    "bootstrap_expect": ${bootstrap},
    "bind_addr": "0.0.0.0",
    "connect": {
        "enabled": true
    },
    "encrypt": ${encryption_key},
    "encrypt_verify_incoming": true,
    "encrypt_verify_outgoing": true,
    "enable_local_script_checks": false,
    "leave_on_terminate": true,
    "log_level": "INFO",
    "ports": {
        "http": 8500
    },
    "retry_join": ["192.168.94.139","192.168.94.138","192.168.94.137"],
    "server": true,
    "ui": true,
    "acl": {
        "enabled": true,
        "default_policy": "deny",
        "down_policy": "extend-cache",
        "tokens": {
            "master": "${consul_acl_token}",
            "default": "${consul_acl_token}"
        }
    }
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

echo "# Enabling and Starting Consul Service"
echo "--------------------------------------"

sudo systemctl enable consul
sudo systemctl start consul

echo "# Wait until Consul Server is responsive"
echo "----------------------------------------"

while [ -z "$(curl -s http://${ip_address}:8500/v1/status/leader)" ]; do
  sleep 3
done

echo "# Adding Consul License to Server if Enterprise Version"
echo "---------------------------------"

export CONSUL_HTTP_TOKEN="${consul_acl_token}"
export CONSUL_HTTP_ADDR="http://${ip_address}:8500"

if [[ $consul_version = *'+ent'* ]]; then
consul license put "${license}"
fi

echo "# Adding Default Policy for Agent"
echo "---------------------------------"

export CONSUL_HTTP_TOKEN="${consul_acl_token}"
sudo tee ~/agent-policy.hcl > /dev/null <<EOF
node_prefix "" {
    policy = "write"
}
service_prefix "" {
    policy = "read"
}
EOF

consul acl policy create -name "agent-token" -description "Agent Token Policy" -rules @agent-policy.hcl

echo "# Installing and Configuring DNSMASQ"
echo "------------------------------------"

sudo apt-get install -y dnsmasq
sudo tee /etc/dnsmasq.d/10-consul > /dev/null <<"EOF"
server=/consul/127.0.0.1#8600
no-poll
server=8.8.8.8
server=8.8.4.4
cache-size=0
EOF
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq