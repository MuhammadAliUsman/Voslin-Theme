#!/bin/bash

# ==========================================
# Voslin Theme Auto Installer
# Fully Automatic Version
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/sonic-hedgehog/voslin-theme.git"
BRANCH="main"

# Detect Paymenter directory
detect_paymenter() {

echo -e "${BLUE}Searching for Paymenter installation...${NC}"

for dir in /var/www/paymenter /var/www/html/paymenter /var/www/*; do
    if [ -d "$dir/themes" ]; then
        PAYMENTER_DIR="$dir"
        break
    fi
done

if [ -z "$PAYMENTER_DIR" ]; then
    echo -e "${RED}Paymenter installation not found.${NC}"
    exit 1
fi

echo -e "${GREEN}Paymenter found at: $PAYMENTER_DIR${NC}"

THEME_DIR="$PAYMENTER_DIR/themes/voslintheme"

}

install_dependencies(){

echo -e "${YELLOW}Installing dependencies...${NC}"

apt update -y
apt install -y git curl nodejs npm

# Install vite globally
npm install -g vite

}

install_theme(){

TMP_DIR="/tmp/voslin_install"

echo -e "${BLUE}Preparing installation...${NC}"

rm -rf $TMP_DIR
mkdir -p $TMP_DIR

echo -e "${YELLOW}Downloading Voslin Theme...${NC}"

git clone -b $BRANCH $REPO_URL $TMP_DIR

echo -e "${YELLOW}Removing old theme if exists...${NC}"

rm -rf $THEME_DIR

echo -e "${YELLOW}Moving theme files...${NC}"

mv $TMP_DIR/themes/* $PAYMENTER_DIR/themes/

}

build_theme(){

echo -e "${BLUE}Building theme with vite...${NC}"

cd $PAYMENTER_DIR

node vite.js voslintheme

}

apply_theme(){

echo -e "${BLUE}Applying theme...${NC}"

cd $PAYMENTER_DIR

php artisan p:settings:change-theme voslintheme

}

cleanup(){

echo -e "${YELLOW}Cleaning temporary files...${NC}"

rm -rf /tmp/voslin_install

}

main(){

clear

echo -e "${GREEN}"
echo "====================================="
echo " Voslin Theme Auto Installer"
echo "====================================="
echo -e "${NC}"

detect_paymenter
install_dependencies
install_theme
build_theme
apply_theme
cleanup

echo -e "${GREEN}====================================="
echo "Voslin Theme Installed Successfully!"
echo "====================================="
echo -e "${NC}"

}

main
