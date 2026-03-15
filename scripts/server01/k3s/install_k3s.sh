#!/bin/bash
# Check the script is being run by root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use 'sudo' to execute this script."
  exit 1
fi

curl -L https://get.k3s.io | INSTALL_K3S_CHANNEL=stable INSTALL_K3S_VERSION=v1.34.5+k3s1 sh -s - --config=/home/devops/git/devops/scripts/server01/k3s/k3s-config.yaml

# mkdir -p /home/devops/.kube && cp /etc/rancher/k3s/k3s.yaml /home/devops/.kube/config && chmod 600 /home/devops/.kube/config && chown devops:devops /home/devops/.kube/config

# steps to upgrade: 1. systemctl stop k3s 2. purge cilium-maintained network link and rules(see below) 3. k3s-killall.sh 4. install new version of k3s

# Before running k3s-killall.sh or k3s-uninstall.sh, you must manually remove cilium_host, cilium_net and cilium_vxlan interfaces.
# If you fail to do this, you may lose network connectivity to the host when K3s is stopped
# Commands:
# ip link delete cilium_host
# ip link delete cilium_net
# ip link delete cilium_vxlan

# Additionally, iptables rules for cilium should be removed.
# Commands:
# iptables-save | grep -iv cilium | iptables-restore
# ip6tables-save | grep -iv cilium | ip6tables-restore
