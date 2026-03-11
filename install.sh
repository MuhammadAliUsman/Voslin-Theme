#!/bin/bash
# ===============================================
# Voslin Theme Full Auto Installer - Node 18 safe
# ===============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Settings
PAYMENTER_DIR="/var/www/paymenter"
THEME_NAME="voslintheme"
REPO_URL="https://github.com/sonic-hedgehog/voslin-theme.git"
TMP_DIR="/tmp/voslin_install"

clear
echo -e "${GREEN}======================================="
echo "   Voslin Theme Full Auto Installer"
echo -e "=======================================${NC}"

# ------------------------
# Fix old apt sources
# ------------------------
echo -e "${YELLOW}Cleaning old apt sources...${NC}"
rm -f /etc/apt/sources.list.d/mariadb.list.old_1 2>/dev/null

# ------------------------
# Remove old Node versions
# ------------------------
echo -e "${BLUE}Removing old NodeJS and conflicting packages...${NC}"
apt remove -y nodejs npm libnode-dev 2>/dev/null
apt autoremove -y
apt --fix-broken install -y

# ------------------------
# Install system dependencies
# ------------------------
echo -e "${BLUE}Installing system dependencies...${NC}"
apt update -y
apt install -y curl git sudo build-essential

# ------------------------
# Install Node 18 LTS
# ------------------------
echo -e "${BLUE}Installing Node 18 LTS...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs
echo -e "${GREEN}Node Version: $(node -v)${NC}"
echo -e "${GREEN}NPM Version: $(npm -v)${NC}"

# ------------------------
# Install Vite globally
# ------------------------
echo -e "${YELLOW}Installing Vite globally...${NC}"
npm install -g vite

# ------------------------
# Go to Paymenter
# ------------------------
cd $PAYMENTER_DIR || { echo -e "${RED}Paymenter not found at $PAYMENTER_DIR${NC}"; exit 1; }

# ------------------------
# Ensure package.json type module
# ------------------------
echo -e "${YELLOW}Setting type=module in package.json...${NC}"
if ! grep -q '"type": "module"' package.json; then
    jq '. + {"type":"module"}' package.json > package.tmp.json && mv package.tmp.json package.json
fi

# ------------------------
# Install npm dependencies
# ------------------------
echo -e "${BLUE}Installing npm dependencies...${NC}"
npm install

# ------------------------
# Prepare temp directory
# ------------------------
echo -e "${YELLOW}Preparing temporary folder...${NC}"
rm -rf $TMP_DIR
mkdir -p $TMP_DIR

# ------------------------
# Download Voslin Theme
# ------------------------
echo -e "${YELLOW}Downloading Voslin Theme...${NC}"
git clone $REPO_URL $TMP_DIR

# ------------------------
# Remove old theme
# ------------------------
echo -e "${YELLOW}Removing old theme if exists...${NC}"
rm -rf $PAYMENTER_DIR/themes/$THEME_NAME

# ------------------------
# Move new theme
# ------------------------
echo -e "${YELLOW}Installing new theme...${NC}"
mv $TMP_DIR/themes/* $PAYMENTER_DIR/themes/

# ------------------------
# Build theme
# ------------------------
echo -e "${BLUE}Building theme with Node 18 + Vite + Tailwind...${NC}"
node vite.js $THEME_NAME

if [ $? -ne 0 ]; then
    echo -e "${RED}Theme build failed. Exiting.${NC}"
    exit 1
fi

# ------------------------
# Apply theme (auto-detect correct artisan command)
# ------------------------
echo -e "${BLUE}Applying Voslin Theme...${NC}"
ARTISAN_CMD=$(php artisan list | grep theme | awk '{print $1}' | head -n1)

if [ -z "$ARTISAN_CMD" ]; then
    echo -e "${RED}No artisan theme command found. You must apply the theme manually.${NC}"
else
    php artisan $ARTISAN_CMD $THEME_NAME
    echo -e "${GREEN}Theme applied using command: $ARTISAN_CMD${NC}"
fi

# ------------------------
# Cleanup
# ------------------------
echo -e "${YELLOW}Cleaning temporary files...${NC}"
rm -rf $TMP_DIR

# ------------------------
# Restart services
# ------------------------
echo -e "${BLUE}Restarting PHP-FPM and Paymenter services...${NC}"
systemctl restart php8.3-fpm 2>/dev/null
systemctl restart paymenter 2>/dev/null

# ------------------------
# Done
# ------------------------
echo -e "${GREEN}======================================="
echo " Voslin Theme Installed Successfully!"
echo " Node 18 + Vite + Tailwind build fixed"
echo "======================================="
echo -e "${NC}"
