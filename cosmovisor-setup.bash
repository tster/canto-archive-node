#!/bin/sh

# Update / Upgrade

echo "Updating and upgrading system..."

sudo apt update
sudo apt upgrade

# Install dependencies

echo "Installing dependencies..."

sudo snap install go --classic
sudo apt-get install git
sudo apt-get install gcc
sudo apt-get install make

# Create Cosmovisor Folders

echo "Creating Cosmovisor folders..."

mkdir -p ~/.cantod/cosmovisor/genesis/bin
mkdir -p ~/.cantod/cosmovisor/upgrades

echo "Installing genesis binary..."

# Install Genesis Binary
git clone https://github.com/Canto-Network/Canto.git

cd Canto
git checkout v1.0.0
make install

cp ~/go/bin/cantod ~/bin/

# Initialize cantod and Move Binary
echo "Initializing cantod..."

cantod init archive --chain-id canto_7700-1
cp ~/bin/cantod ~/.cantod/cosmovisor/genesis/bin

# Install v2.0.2 Binary
# v2.0.2 is a retrospective patch which mitigates AppHash errors previously thrown during syncing of archive nodes
# We save this binary as v2.0.0, since Cosmovisor will look for this version at the upgrade block
echo "Installing v2.0.2..."

cd ~/Canto
git checkout v2.0.2
make install

mkdir -p ~/.cantod/cosmovisor/upgrades/v2.0.0/bin

cp ~/go/bin/cantod ~/.cantod/cosmovisor/upgrades/v2.0.0/bin

# Install v3.0.0 Binary
echo "Installing v3.0.0..."

git checkout v3.0.0
make install

mkdir -p ~/.cantod/cosmovisor/upgrades/v3.0.0/bin

cp ~/go/bin/cantod ~/.cantod/cosmovisor/upgrades/v3.0.0/bin

# Install v4.0.0 Binary
echo "Installing v4.0.0..."

git checkout v4.0.0
make install

mkdir -p ~/.cantod/cosmovisor/upgrades/v4.0.0/bin

cp ~/go/bin/cantod ~/.cantod/cosmovisor/upgrades/v4.0.0/bin

# Install v5.0.0 Binary
echo "Installing v5.0.0..."

git checkout v5.0.0
make install

mkdir -p ~/.cantod/cosmovisor/upgrades/v5.0.0/bin

cp ~/go/bin/cantod ~/.cantod/cosmovisor/upgrades/v5.0.0/bin

# Install v6.0.0 Binary
echo "Installing v6.0.0..."

git checkout v6.0.0
make install

mkdir -p ~/.cantod/cosmovisor/upgrades/v6.0.0/bin

cp ~/go/bin/cantod ~/.cantod/cosmovisor/upgrades/v6.0.0/bin

# Finalize Config
echo "Configuring cantod..."

cd ~/.cantod/config
rm genesis.json
wget https://github.com/Canto-Network/Canto/raw/genesis/Networks/Mainnet/genesis.json

# Add seed peer to config.toml
sed -i 's/seeds = ""/seeds = "ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:15556"/g' $HOME/.cantod/config/config.toml

# Set minimum gas price in app.toml
sed -i 's/minimum-gas-prices = "0acanto"/minimum-gas-prices = "0.0001acanto"/g' $HOME/.cantod/config/app.toml

# Set pruning in app.toml
sed -i 's/pruning = "default"/pruning = "nothing"/g' $HOME/.cantod/config/app.toml

# Create systemd Service
echo "Creating and enabling systemd service..."

sudo cat > /etc/systemd/system/cantod.service << EOF
[Unit]
Description=Archive Node
After=network.target

[Service]
User=USER
ExecStart=/home/USER/go/bin/cosmovisor start
Restart=always
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_NAME=cantod"
Environment="DAEMON_HOME=/home/USER/.cantod"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Reload service files
sudo systemctl daemon-reload

# Create the symlink
sudo systemctl enable cantod.service

# Start the node
echo "Starting sync..."

sudo systemctl start cantod

# Show logs
journalctl -u cantod -f