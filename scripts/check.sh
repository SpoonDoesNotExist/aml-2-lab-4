#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
WEB=$(terraform output -raw web_public_ip)
WORKER=$(terraform output -raw worker_private_ip)
USER_NAME=$(terraform console <<< 'var.ssh_user' | tr -d '"')
cat > .local/ssh_config <<CONFIG
Host lab-web lab-worker
  User $USER_NAME
  IdentityFile $PWD/.local/id_ed25519
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
  UserKnownHostsFile $PWD/.local/known_hosts
  ConnectTimeout 10
  BatchMode yes
Host lab-web
  HostName $WEB
Host lab-worker
  HostName $WORKER
  ProxyCommand ssh -F $PWD/.local/ssh_config -W %h:%p lab-web
CONFIG
printf '\n--- Public HTTP on port 8080 ---\n'
curl --fail --show-error --max-time 20 -i "http://$WEB:8080"
printf '\n--- Web cloud-init and Docker ---\n'
ssh -F .local/ssh_config lab-web 'sudo cloud-init status --wait; sudo docker ps; sudo ss -ltn'
printf '\n--- Worker via web (SSH jump host) ---\n'
ssh -F .local/ssh_config lab-worker 'hostname; sudo cloud-init status --wait; python3 --version; systemctl is-active lab-worker; sudo tail -3 /var/log/worker.log'
printf '\n--- Worker port 8080 from web must be blocked ---\n'
ssh -F .local/ssh_config lab-web "python3 -c 'import socket; s=socket.socket(); s.settimeout(3); result=s.connect_ex((\"$WORKER\",8080)); print(\"worker:8080 connect_ex =\", result); assert result != 0'"
