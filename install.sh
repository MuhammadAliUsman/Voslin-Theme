#!/bin/bash

# ==========================================
# Voslin Theme Full Auto Installer
# Compatible with Node 20, Vite + Tailwind
# ==========================================

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ----------------------
# Settings
# ----------------------
PAYMENTER_DIR="/var/www/paymenter"
THEME_NAME="voslintheme"
REPO_URL="https://github.com/sonic-hedgehog/voslin-theme.git"
TMP_DIR="/tmp/voslin_install"

echo -e "${GREEN}"
echo "======================================="
echo "   Voslin Theme Full Auto Installer"
echo "======================================="
echo -e "${NC}"

# ----------------------
# Fix apt sources
# ----------------------
echo -e "${YELLOW}Cleaning old apt sources...${NC}"
rm -f /etc/apt/sources.list.d/mariadb.list.old_1

# ----------------------
# Remove old Node versions
# ----------------------
echo -e "${BLUE}Removing old NodeJS and conflicting packages...${NC}"
apt remove -y nodejs npm libnode-dev 2>/dev/null
apt autoremove -y
apt --fix-broken install -y

# ----------------------
# Install dependencies
# ----------------------
echo -e "${BLUE}Installing system dependencies...${NC}"
apt update -y
apt install -y curl git sudo build-essential

# ----------------------
# Install Node 20
# ----------------------
echo -e "${BLUE}Installing NodeJS 20...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

echo -e "${GREEN}Node Version: $(node -v)${NC}"
echo -e "${GREEN}NPM Version: $(npm -v)${NC}"

# ----------------------
# Install Vite
# ----------------------
echo -e "${YELLOW}Installing Vite globally...${NC}"
npm install -g vite

# ----------------------
# Go to Paymenter directory
# ----------------------
cd $PAYMENTER_DIR || { echo -e "${RED}Paymenter not found at $PAYMENTER_DIR${NC}"; exit 1; }

# ----------------------
# Install npm dependencies
# ----------------------
echo -e "${BLUE}Installing npm dependencies...${NC}"
npm install

# ----------------------
# Prepare temp folder
# ----------------------
echo -e "${YELLOW}Preparing temporary directory...${NC}"
rm -rf $TMP_DIR
mkdir -p $TMP_DIR

# ----------------------
# Download Voslin Theme
# ----------------------
echo -e "${YELLOW}Downloading Voslin Theme...${NC}"
git clone $REPO_URL $TMP_DIR

# ----------------------
# Remove old theme
# ----------------------
echo -e "${YELLOW}Removing old theme if exists...${NC}"
rm -rf $PAYMENTER_DIR/themes/$THEME_NAME

# ----------------------
# Install new theme
# ----------------------
echo -e "${YELLOW}Installing new theme...${NC}"
mv $TMP_DIR/themes/* $PAYMENTER_DIR/themes/

# ----------------------
# Build theme with ESM-safe Vite
# ----------------------
echo -e "${BLUE}Building theme with Vite (ESM-safe)...${NC}"
cd $PAYMENTER_DIR/themes/$THEME_NAME
npm install
npx vite build

if [ $? -ne 0 ]; then
  echo -e "${RED}Theme build failed. Exiting.${NC}"
  exit 1
fi

cd $PAYMENTER_DIR

# ----------------------
# Apply theme
# ----------------------
echo -e "${BLUE}Applying Voslin Theme...${NC}"
php artisan app:theme:set $THEME_NAME

# ----------------------
# Cleanup
# ----------------------
echo -e "${YELLOW}Cleaning temporary files...${NC}"
rm -rf $TMP_DIR

# ----------------------
# Restart services
# ----------------------
echo -e "${BLUE}Restarting PHP-FPM and Paymenter...${NC}"
systemctl restart php8.3-fpm 2>/dev/null
systemctl restart paymenter 2>/dev/null

# ----------------------
# Done
# ----------------------
echo -e "${GREEN}"
echo "======================================="
echo " Voslin Theme Installed Successfully!"
echo " Node 20 + Vite + Tailwind are supported"
echo "======================================="
echo -e "${NC}"
