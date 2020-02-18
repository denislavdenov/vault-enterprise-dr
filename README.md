# Sample repo showing how to Create a Vault Enterprise DR clusters

This repo is showing how you can automate the creation of 2 Vault Enterprise clusters and enable the DR function between them marking one as Primary and the other as Secondary.

3 node Consul Cluster is also created that is required for this High Availability scenario.

Desried versions of Consul and Vault Enterprise can be edited in Vagrantfile.

## Requirements:

- Vagrant
- This setup requires 14GB of RAM, you can modify that in Vagrantfile 
- Virtualbox
- valid Vault Enterprise license: `payload.json` file needs to be created into a `license/` folder in the root repo directory

`payload.json`

```
{
    "text": "..."
}

```


## What to do:

You only need to do `vagrant up` and you will have 3 Consul server cluster serving as backend for 2 Vault Enterprise clusters in order to enable Disaster Recovery

