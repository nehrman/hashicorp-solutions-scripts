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
$ git clone https://github.com/nehrman/hashicorp-solutions-scripts
```


## For Vault 

- Look at the variables :

```
##################################################################################################
# How to use this script :                                                                       #
#   ./vault_single_server.sh vault_version vault _enterprise os_type os vault_backend license    #
#                                                                                                #
# Vault_version :                                                                                #
#   - OSS : 1.1.1                                                                                #
#   - Ent: 1.1.1+ent (Default)                                                                   #
# os_type :                                                                                      #
#   - linux_386 or linux_amd64 (Default)                                                         #
#   - linux_arm or linux_arm64                                                                   #
#   - freebsd_386 or freebsd_amd64                                                               #
#   - darwin_386 or darwin_amd64                                                                 #
#   - solaris_amd64                                                                              #
# os :                                                                                           #
#   - redhat                                                                                     #
#   - centos                                                                                     #
#   - ubuntu (Default)                                                                           #
#   - solaris                                                                                    #
#   - freebsd                                                                                    #
#   - macosx                                                                                     #
# Backend :                                                                                      #
#   - consul : Use Consul as backend. (Local agent is required on Vault Server)                  #
#   - file : Use local disk as data directory for Vault Server (Test purpose)                    # 
# license : Enter the license number that Hashicorp provides                                     #
##################################################################################################
```

#### Vault Example : 
```
vaultadmin@vault01:~$ ./vault_single_server.sh 1.1.2 false
```
It will download, install and configure Vault version 1.1.2 Open Source automatically on ubuntu OS.


### For Consul 

``` 
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
# license : Enter the license number that Hashicorp provides                              #
# encryption_key : The key must be 16-Bits, base64 encoded.                               #                                          
# consul_acl_token : Like Encryption Key, must be 16-Bits, base64 encoded.                #
###########################################################################################

``` 

#### Vault Example : 
```
vaultadmin@vault01:~$ ./consul_server.sh 1.5.1 false
```
It will download, install and configure Vault version 1.1.2 Open Source automatically on ubuntu OS.

## Special thanks

* **Guy Barros** - For Inspiring me with his great content [Github](https://github.com/guybarros)

## Authors

* **Nicolas Ehrman** - *Initial work* - [Hashicorp](https://www.hashicorp.com)

