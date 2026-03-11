#!/bin/bash

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PAYMENTER_DIR="/var/www/paymenter"
THEME_NAME="voslintheme"
REPO_URL="https://github.com/sonic-hedgehog/voslin-theme.git"

echo -e "${GREEN}"
echo "======================================="
echo "   Voslin Theme Auto Installer"
echo "======================================="
echo -e "${NC}"

echo -e "${YELLOW}Fixing apt sources...${NC}"
rm -f /etc/apt/sources.list.d/mariadb.list.old_1

echo -e "${BLUE}Removing old NodeJS versions...${NC}"
apt remove -y nodejs npm libnode-dev 2>/dev/null
apt autoremove -y
apt --fix-broken install -y

echo -e "${BLUE}Installing dependencies...${NC}"
apt update -y
apt install -y curl git sudo

echo -e "${BLUE}Installing NodeJS 20...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

echo -e "${GREEN}Node installed: $(node -v)${NC}"
echo -e "${GREEN}NPM installed: $(npm -v)${NC}"

echo -e "${YELLOW}Installing Vite...${NC}"
npm install -g vite

echo -e "${BLUE}Going to Paymenter directory...${NC}"
cd $PAYMENTER_DIR || { echo -e "${RED}Paymenter not found at /var/www/paymenter${NC}"; exit 1; }

echo -e "${BLUE}Installing npm dependencies...${NC}"
npm install

TMP_DIR="/tmp/voslin_install"

echo -e "${YELLOW}Preparing installation directory...${NC}"
rm -rf $TMP_DIR
mkdir -p $TMP_DIR

echo -e "${YELLOW}Downloading Voslin Theme...${NC}"
git clone $REPO_URL $TMP_DIR

echo -e "${YELLOW}Removing old theme...${NC}"
rm -rf $PAYMENTER_DIR/themes/$THEME_NAME

echo -e "${YELLOW}Installing theme...${NC}"
mv $TMP_DIR/themes/* $PAYMENTER_DIR/themes/

echo -e "${BLUE}Building theme with vite...${NC}"
node vite.js $THEME_NAME

if [ $? -ne 0 ]; then
echo -e "${RED}Theme build failed.${NC}"
exit 1
fi

echo -e "${BLUE}Applying theme...${NC}"
php artisan app:theme:set $THEME_NAME

echo -e "${YELLOW}Cleaning temporary files...${NC}"
rm -rf $TMP_DIR

echo -e "${BLUE}Restarting services...${NC}"
systemctl restart php8.3-fpm 2>/dev/null
systemctl restart paymenter 2>/dev/null

echo -e "${GREEN}"
echo "======================================="
echo " Voslin Theme Installed Successfully!"
echo "======================================="
echo -e "${NC}"
