#!/bin/bash
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release jq
              
# Install Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
              
apt update -y
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              
# Enable docker service and grant permissions to default ubuntu user
jq -n '{hosts: ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]}' > /etc/docker/daemon.json
systemctl enable docker
systemctl restart docker
usermod -aG docker ubuntu