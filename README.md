# A complete set of Scripts to deploy and configure Hashicorp Products 

The main goal of this project is to have a set of scripts that allow me to deploy easily our solutions.

To cover most of the deployment use cases, I've created differents scripts :

## Consul
- consul_client.sh :
    - Deploy a client and configure it to automatically join Consul Cluster
- consul_single_server.sh :
    - Deploy Consul Server on Single node for testing purpose 
- consul_server.sh :
    - Deploy Consul Server in cluster mode
- consul_snapshot.sh (WIP):
    - Deploy and configure Consul snapshot agent to automate backup

## Vault
- vault_single_server.sh :
    - Deploy a single Vault server, using Consul or File as backend, initialize it and unseal it.

More to come here ....


## Pre Requisites

No specific pre requisites for this a part to able to use a terminal and to know a little bit of bash scripts. :)


## How to use it 

- Clone the repo on your laptop :

```
$ git clone https://github.com/nehrman/terraform-vault-az-demo
```

- Copy and rename **terraform.tfvars.example** :

```
$ cp terraform.tfvars.example terraform.tfvars
```

- Customize **tfvars** file with your own values :

```
################################################################################
#                                                                              #
# This file must be rename (without .example) and customize for your own need. #
#                                                                              #
################################################################################

# Username that will be used to connect to VMs and by Ansible Playbook

global_admin_username = "yourname"

# SSH Keys that will be used to connect to nodes

id_rsa_path = "~/.ssh/id_rsa"
ssh_public_key = ["ssh-rsa kjdkjdkjskdfhsjd;v,,wxkvcjfdlqsjk"]

# Global Variables to determine location, name and more 

tf_az_location = "francecentral"
tf_az_name     = "demo"
tf_az_env      = "dev"
tf_az_prefix   = "hashi"

# Be careful with storage account name. Must be lower case (it's in the code) and not more than 16 characters

tf_az_storage_account_name = "hashivaultsto"

# Here, enter the number of instance you want to deploy

tf_az_bastion_nb_instance = "1"
tf_az_consul_nb_instance  = "3"
tf_az_vault_nb_instance   = "2"

# Package's version to install on nodes 

consul_version  = "1.4.2"
vault_version   = "1.0.2"
```

## Special thanks

* **Guy Barros** - For Inspiring me with his great content [Github](https://github.com/guybarros)

## Authors

* **Nicolas Ehrman** - *Initial work* - [Hashicorp](https://www.hashicorp.com)

