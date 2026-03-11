#!/bin/bash

# ==========================================
# Voslin Theme Auto Installer
# Fixed for Paymenter + Node 20
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/sonic-hedgehog/voslin-theme.git"
BRANCH="main"

PAYMENTER_DIR="/var/www/paymenter"
THEME_DIR="$PAYMENTER_DIR/themes/voslintheme"

clear

echo -e "${GREEN}"
echo "======================================"
echo " Voslin Theme Auto Installer"
echo "======================================"
echo -e "${NC}"

# Install dependencies
echo -e "${YELLOW}Installing required packages...${NC}"

apt update -y
apt install -y curl git sudo

# Install NodeJS 20
echo -e "${BLUE}Installing NodeJS 20...${NC}"

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

echo -e "${GREEN}Node Version:${NC} $(node -v)"
echo -e "${GREEN}NPM Version:${NC} $(npm -v)"

# Install vite
echo -e "${YELLOW}Installing Vite...${NC}"
npm install -g vite

# Go to paymenter
cd $PAYMENTER_DIR || { echo "Paymenter not found!"; exit 1; }

# Install node dependencies
echo -e "${BLUE}Installing npm dependencies...${NC}"
npm install

# Prepare temp dir
TMP_DIR="/tmp/voslin_install"

rm -rf $TMP_DIR
mkdir -p $TMP_DIR

echo -e "${YELLOW}Downloading Voslin Theme...${NC}"

git clone -b $BRANCH $REPO_URL $TMP_DIR

echo -e "${YELLOW}Removing old theme if exists...${NC}"

rm -rf $THEME_DIR

echo -e "${YELLOW}Moving theme files...${NC}"

mv $TMP_DIR/themes/* $PAYMENTER_DIR/themes/

# Build theme
echo -e "${BLUE}Building theme with Vite...${NC}"

node vite.js voslintheme

if [ $? -ne 0 ]; then
echo -e "${RED}Theme build failed!${NC}"
exit 1
fi

# Apply theme
echo -e "${BLUE}Applying Voslin Theme...${NC}"

php artisan app:theme:set voslintheme

# Cleanup
echo -e "${YELLOW}Cleaning temporary files...${NC}"

rm -rf $TMP_DIR

# Restart services
echo -e "${BLUE}Restarting services...${NC}"

systemctl restart php8.3-fpm
systemctl restart paymenter 2>/dev/null

echo -e "${GREEN}"
echo "======================================"
echo " Voslin Theme Installed Successfully!"
echo "======================================"
echo -e "${NC}"
