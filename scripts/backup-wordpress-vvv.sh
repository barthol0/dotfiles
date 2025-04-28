#!/bin/bash

# --- Default Configuration ---
# Core Settings
HOME_DIR="$HOME"
SITE_NAME="wordpress-one"
DB_NAME="wordpress-one"

# VVV Paths (base only, dependent paths defined later)
VVV_ROOT="${HOME_DIR}/vvv-local"
VVV_SITES_PATH="${VVV_ROOT}/www"

# Backup Settings (base only, dependent paths defined later)
BASE_BACKUP_DIR="${HOME_DIR}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# MySQL Credentials
MYSQL_USER="root"
MYSQL_PASS="root"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# --- Command Line Options ---
while getopts "s:d:" opt; do
    case $opt in
    s)
        SITE_NAME="$OPTARG"
        DB_NAME="$SITE_NAME"
        ;;
    d) DB_NAME="$OPTARG" ;;
    ?)
        echo -e "${RED}Usage: $0 [-s site_name] [-d db_name]${NC}"
        echo "  -s: Site name (default: wordpress-one)"
        echo "  -d: Database name (default: matches site_name)"
        exit 1
        ;;
    esac
done

# --- Define Dependent Variables After Options ---
SITE_SOURCE="${VVV_SITES_PATH}/${SITE_NAME}"
PUBLIC_HTML_PATH="${SITE_SOURCE}/public_html"
BACKUP_DIR="${BASE_BACKUP_DIR}/${SITE_NAME}_backup_${TIMESTAMP}"
FILES_ZIP="${BACKUP_DIR}/${SITE_NAME}_files_${TIMESTAMP}.zip"
DB_BACKUP_FILE="${BACKUP_DIR}/${SITE_NAME}_backup_${TIMESTAMP}.sql"
DB_SOURCE="/srv/www/${SITE_NAME}/${SITE_NAME}_backup_${TIMESTAMP}.sql"

# --- Functions ---
confirm() {
    while true; do
        read -r -p "$1 [Y/n]: " response
        case "$response" in
        [yY] | "") return 0 ;;
        [nN]) return 1 ;;
        *) echo -e "${RED}Error: Invalid input. Please enter y, Y, n, N, or press Enter for Yes.${NC}" ;;
        esac
    done
}

detect_vagrant_ip() {
    echo -e "${GREEN}Detecting Vagrant IP and SSH config...${NC}"
    cd "$VVV_ROOT" || {
        echo -e "${RED}Error: Cannot access $VVV_ROOT${NC}"
        exit 1
    }
    VVV_IP=$(vagrant ssh-config | grep -i "HostName" | awk '{print $2}')
    [ -z "$VVV_IP" ] && {
        echo -e "${RED}Error: Could not detect Vagrant IP${NC}"
        exit 1
    }
    VVV_PORT=$(vagrant ssh-config | grep -i "Port" | awk '{print $2}')
    VVV_KEY=$(vagrant ssh-config | grep -i "IdentityFile" | head -n 1 | awk '{print $2}' | tr -d '"')
    [ -z "$VVV_PORT" ] || [ -z "$VVV_KEY" ] && {
        echo -e "${RED}Error: Could not extract SSH config${NC}"
        exit 1
    }
    echo "Vagrant SSH: IP=$VVV_IP | Port=$VVV_PORT | Key=$VVV_KEY"
}

setup_backup_dir() {
    echo -e "${GREEN}Step 1: Setting up backup directory...${NC}"
    confirm "Create backup directory at $BACKUP_DIR?" || {
        echo "Skipping backup."
        exit 1
    }
    mkdir -p "$BACKUP_DIR" || {
        echo -e "${RED}Error: Failed to create $BACKUP_DIR${NC}"
        exit 1
    }
    echo "Directory ready."
}

backup_files() {
    echo -e "${GREEN}Step 2: Backing up WordPress files...${NC}"
    confirm "Copy and zip files from $PUBLIC_HTML_PATH?" || {
        echo "Skipping file backup."
        exit 1
    }
    cd "$SITE_SOURCE" || {
        echo -e "${RED}Error: Cannot access $SITE_SOURCE${NC}"
        exit 1
    }
    cp -r public_html "$BACKUP_DIR/" || {
        echo -e "${RED}Error: Failed to copy files${NC}"
        exit 1
    }
    cd "$BACKUP_DIR" || exit 1
    zip -r "$FILES_ZIP" public_html || {
        echo -e "${RED}Error: Failed to zip files${NC}"
        exit 1
    }
    rm -rf "$BACKUP_DIR/public_html" && echo "Temporary files folder removed."
    echo "Files backed up: $FILES_ZIP"
}

backup_database() {
    echo -e "${GREEN}Step 3: Backing up database...${NC}"
    confirm "Export database $DB_NAME from VVV VM?" || {
        echo "Skipping database export."
        exit 1
    }
    cd "$VVV_ROOT" || {
        echo -e "${RED}Error: Cannot access $VVV_ROOT${NC}"
        exit 1
    }
    vagrant ssh -c "mysqldump -u $MYSQL_USER -p$MYSQL_PASS $DB_NAME > $DB_SOURCE" || {
        echo -e "${RED}Error: Failed to export database${NC}"
        exit 1
    }
    echo "Database exported on VM."
}

retrieve_database() {
    echo -e "${GREEN}Step 4: Retrieving database backup...${NC}"
    confirm "Copy database backup from VM to $BACKUP_DIR?" || {
        echo "Skipping database retrieval."
        exit 1
    }
    cd "$VVV_ROOT" || {
        echo -e "${RED}Error: Cannot access $VVV_ROOT${NC}"
        exit 1
    }
    scp -P "$VVV_PORT" -i "$VVV_KEY" -o StrictHostKeyChecking=no "vagrant@$VVV_IP:$DB_SOURCE" "$BACKUP_DIR/" || {
        echo -e "${RED}Error: Failed to copy database backup${NC}"
        exit 1
    }
    echo "Database retrieved: $DB_BACKUP_FILE"
    # Clean up the .sql file on the VM
    vagrant ssh -c "rm -f $DB_SOURCE" || {
        echo -e "${RED}Warning: Failed to clean up $DB_SOURCE on VM${NC}"
    }
    echo "Temporary database file removed from VM."
}

verify_backup() {
    echo -e "${GREEN}Step 5: Verifying backup...${NC}"
    if [ -f "$FILES_ZIP" ] && [ -f "$DB_BACKUP_FILE" ]; then
        echo -e "${GREEN}Backup completed successfully!${NC}"
        echo "Files ZIP: $FILES_ZIP"
        echo "Database: $DB_BACKUP_FILE"
        echo "Note: Original files on VM preserved."
    else
        echo -e "${RED}Error: Backup incomplete. Check $BACKUP_DIR${NC}"
        exit 1
    fi
}

# --- Main Execution ---
echo -e "${GREEN}WordPress VVV Backup Script${NC}"
echo "Site: $SITE_NAME | Database: $DB_NAME | Backup Dir: $BACKUP_DIR"
echo "Timestamp: $TIMESTAMP"
echo "Enter y, Y, or press Enter to proceed; n or N to skip."

detect_vagrant_ip
setup_backup_dir
backup_files
backup_database
retrieve_database
verify_backup

exit 0
