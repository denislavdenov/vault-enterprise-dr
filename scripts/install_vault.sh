#!/usr/bin/env bash

# Stop vault if running previously
sudo systemctl stop vault
sleep 5
sudo systemctl status vault


echo $DOMAIN
rm -fr /tmp/vault/data
which unzip curl jq /sbin/route vim sshpass || {
  apt-get update -y
  apt-get install unzip jq net-tools vim curl sshpass -y 
}

mkdir -p /vagrant/pkg/
# insall vault

which vault || {
  pushd /vagrant/pkg
  [ -f vault_${VAULT}_linux_amd64.zip ] || {
    sudo wget https://releases.hashicorp.com/vault/${VAULT}/vault_${VAULT}_linux_amd64.zip
  }

  popd
  pushd /tmp

  sudo unzip /vagrant/pkg/vault_${VAULT}_linux_amd64.zip
  sudo chmod +x vault
  sudo mv vault /usr/local/bin/vault
  popd
}

hostname=$(hostname)

#lets kill past instance
sudo killall vault &>/dev/null
sudo killall vault &>/dev/null
sudo killall vault &>/dev/null

sleep 10

# Create vault user
sudo useradd --system --home /etc/vault.d --shell /bin/false vault

# Create vault service

cat << EOF > /etc/systemd/system/vault.service

[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/config.hcl

[Service]
User=vault
Group=vault
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/config.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitIntervalSec=60
StartLimitBurst=3

[Install]
WantedBy=multi-user.target

EOF

# Copy vault configuration inside /etc/vault.d
sudo mkdir -p /etc/vault.d

cat << EOF > /etc/vault.d/config.hcl

storage "file" {
  path = "/tmp/vault/data"
}

listener "tcp" {
 address     = "127.0.0.1:8200"
 tls_disable = 1
}

EOF

#start vault
sudo systemctl enable vault
sudo systemctl start vault
journalctl -f -u vault.service > /vagrant/logs/${hostname}.log &
sudo systemctl status vault
echo vault started
sleep 3 

export VAULT_ADDR=http://127.0.0.1:8200 

# Change configuration file
sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/config.hcl



# setup .bash_profile
grep VAULT_ADDR ~/.bash_profile || {
  echo export VAULT_ADDR=http://127.0.0.1:8200 | sudo tee -a ~/.bash_profile
}

source ~/.bash_profile

vault operator init > /vagrant/keys.txt
vault operator unseal $(cat /vagrant/keys.txt | grep "Unseal Key 1:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys.txt | grep "Unseal Key 2:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys.txt | grep "Unseal Key 3:" | cut -c15-)
vault login $(cat /vagrant/keys.txt | grep "Initial Root Token:" | cut -c21-)
ROOT_TOKEN=$(cat /vagrant/keys.txt | grep "Initial Root Token:" | cut -c21-)

curl \
    --header "X-Vault-Token: ${ROOT_TOKEN}" \
    --request PUT \
    --data @/vagrant/license/payload.json \
    http://127.0.0.1:8200/v1/sys/license


declare -A vaultserver
vaultserver["client-vault-server1-sofia"]="10.10.46.11"
vaultserver["client-vault-server2-sofia"]="10.10.46.12"
vaultserver["client-vault-server3-sofia"]="10.10.66.13"
vaultserver["client-vault-server4-sofia"]="10.10.66.14"

declare -A vaultpath
vaultpath["client-vault-server1-sofia"]="vault1/"
vaultpath["client-vault-server2-sofia"]="vault1/"
vaultpath["client-vault-server3-sofia"]="vault2/"
vaultpath["client-vault-server4-sofia"]="vault2/"


cat << EOF > /etc/vault.d/config.hcl

listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "${vaultserver[$hostname]}:8201"
  tls_disable      = "true"
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "${vaultpath[$hostname]}"
}

api_addr = "http://${vaultserver[$hostname]}:8200"
cluster_addr = "https://${vaultserver[$hostname]}:8201"

EOF

if [[ "${hostname}" =~ "server1" ]]; then

sudo systemctl restart vault
sleep 5

vault operator init > /vagrant/keys1.txt
vault operator unseal $(cat /vagrant/keys1.txt | grep "Unseal Key 1:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys1.txt | grep "Unseal Key 2:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys1.txt | grep "Unseal Key 3:" | cut -c15-)
vault login $(cat /vagrant/keys1.txt | grep "Initial Root Token:" | cut -c21-)

vault status
    
fi


if [[ "${hostname}" =~ "server2" ]]; then
sudo systemctl restart vault
sleep 5

vault operator unseal $(cat /vagrant/keys1.txt | grep "Unseal Key 1:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys1.txt | grep "Unseal Key 2:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys1.txt | grep "Unseal Key 3:" | cut -c15-)
vault login $(cat /vagrant/keys.1txt | grep "Initial Root Token:" | cut -c21-)

vault status
    
fi

if [[ "${hostname}" =~ "server3" ]]; then

sudo systemctl restart vault
sleep 5

vault operator init > /vagrant/keys3.txt
vault operator unseal $(cat /vagrant/keys3.txt | grep "Unseal Key 1:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys3.txt | grep "Unseal Key 2:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys3.txt | grep "Unseal Key 3:" | cut -c15-)
vault login $(cat /vagrant/keys3.txt | grep "Initial Root Token:" | cut -c21-)


vault status
    
fi


if [[ "${hostname}" =~ "server4" ]]; then

sudo systemctl restart vault
sleep 5

vault operator unseal $(cat /vagrant/keys3.txt | grep "Unseal Key 1:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys3.txt | grep "Unseal Key 2:" | cut -c15-)
vault operator unseal $(cat /vagrant/keys3.txt | grep "Unseal Key 3:" | cut -c15-)
vault login $(cat /vagrant/keys3.txt | grep "Initial Root Token:" | cut -c21-)

vault status



# ENABLING DR
ROOT_TOKEN1=$(cat /vagrant/keys1.txt | grep "Initial Root Token:" | cut -c21-)
curl --header "X-Vault-Token: ${ROOT_TOKEN1}" \
      --request POST \
      --data '{}' \
      http://10.10.46.11:8200/v1/sys/replication/dr/primary/enable


SEC_TOKEN=$(curl --header "X-Vault-Token: ${ROOT_TOKEN1}" \
      --request POST \
      --data '{ "id": "secondary"}' \
      http://10.10.46.11:8200/v1/sys/replication/dr/primary/secondary-token | jq '.wrap_info.token')


tee payload.json <<EOF
{
 "token": ${SEC_TOKEN}
}
EOF

ROOT_TOKEN2=$(cat /vagrant/keys3.txt | grep "Initial Root Token:" | cut -c21-)

curl --header "X-Vault-Token: ${ROOT_TOKEN2}" \
      --request POST \
      --data @payload.json \
      http://10.10.66.13:8200/v1/sys/replication/dr/secondary/enable


sleep 10

curl -s http://10.10.46.11:8200/v1/sys/replication/dr/status
curl -s http://10.10.66.13:8200/v1/sys/replication/dr/status

fi