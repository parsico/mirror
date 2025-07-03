#!/bin/bash
# IRRadar Auto Linux Booster Script
# github.com/IRRadar | t.me/IRRadar

set -e

echo -e "\n🛰️  IRStorm Linux Setup is starting..."
echo -e "🚀 Applying DNS, mirror, Docker install, and final system upgrade..."

########################################
# 1. Set DNS
########################################
echo -e "\n🧭 Setting DNS..."
cat <<EOF | sudo tee /etc/resolv.conf >/dev/null
nameserver 78.157.42.100
nameserver 78.157.42.101
EOF

########################################
# 2. Replace Ubuntu mirrors
########################################
UBUNTU_VERSION=$(lsb_release -rs)
echo -e "\n📦 Configuring APT mirror for Ubuntu $UBUNTU_VERSION..."

if [[ -f /etc/apt/sources.list.d/ubuntu.sources ]]; then
  FILE="/etc/apt/sources.list.d/ubuntu.sources"
  sudo sed -i 's|http://archive.ubuntu.com|http://mirror.manageit.ir|g' "$FILE"
  sudo sed -i 's|http://security.ubuntu.com|http://mirror.manageit.ir|g' "$FILE"
else
  FILE="/etc/apt/sources.list"
  sudo sed -i 's|http://archive.ubuntu.com|http://mirror.manageit.ir|g' "$FILE"
  sudo sed -i 's|http://security.ubuntu.com|http://mirror.manageit.ir|g' "$FILE"
fi

########################################
# 3. Update APT index
########################################
echo -e "\n🔄 Running apt update..."
sudo apt update

########################################
# 4. Install Docker with mirror
########################################
echo -e "\n🐳 Installing Docker..."
curl -fsSL https://raw.githubusercontent.com/manageitir/docker/main/install-ubuntu.sh | sh

# Fallback / ensure mirror is set
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json >/dev/null
{
  "registry-mirrors": [
    "https://docker.manageit.ir"
  ]
}
EOF

# Restart Docker if present
if command -v docker >/dev/null 2>&1; then
  echo -e "\n🔁 Restarting Docker..."
  sudo systemctl restart docker
fi

########################################
# 5. FULL system upgrade
########################################
echo -e "\n⚡ Performing full system upgrade (this may take a while)..."
sudo DEBIAN_FRONTEND=noninteractive apt -y full-upgrade
sudo apt -y autoremove
sudo apt -y clean

echo -e "\n✅ Setup & upgrade completed successfully!"
echo -e "🛰️  IRRadar | Enjoy faster, unblocked package delivery.\n"
