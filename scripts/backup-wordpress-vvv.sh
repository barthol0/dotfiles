#!/bin/bash

# --- Default Configuration ---
SITE_NAME="wordpress-one"      # Default VVV site folder name
DB_NAME="wordpress-one"        # Default database name
VVV_PATH="$HOME/vvv-local/www" # Path to VVV sites, using $HOME
BASE_BACKUP_DIR="$HOME"        # Base backup destination (no site name here)
MYSQL_USER="root"              # VVV MySQL user
MYSQL_PASS="root"              # VVV MySQL password
VVV_ROOT="$HOME/vvv-local"     # Root VVV directory with Vagrantfile

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

while getopts "s:d:" opt; do
    case $opt in
    s) SITE_NAME="$OPTARG" ;;
    d) DB_NAME="$OPTARG" ;;
    ?)
        echo -e "${RED}Usage: $0 [-s site_name] [-d db_name]${NC}"
        echo "  -s: Site name (default: wordpress-one)"
        echo "  -d: Database name (default: wordpress-one)"
        exit 1
        ;;
    esac
done

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${BASE_BACKUP_DIR}/${SITE_NAME}_backup_${TIMESTAMP}"

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
    if [ -z "$VVV_IP" ]; then
        echo -e "${RED}Error: Could not detect Vagrant IP. Is Vagrant running in $VVV_ROOT?${NC}"
        exit 1
    fi
    echo "Vagrant SSH IP: $VVV_IP (from ssh-config)"

    VVV_PORT=$(vagrant ssh-config | grep -i "Port" | awk '{print $2}')
    VVV_KEY=$(vagrant ssh-config | grep -i "IdentityFile" | head -n 1 | awk '{print $2}' | tr -d '"')
    if [ -z "$VVV_PORT" ] || [ -z "$VVV_KEY" ]; then
        echo -e "${RED}Error: Could not extract SSH port or key from vagrant ssh-config${NC}"
        exit 1
    fi
    echo "SSH Port: $VVV_PORT | Identity File: $VVV_KEY"
}

setup_backup_dir() {
    echo -e "${GREEN}Step 1: Setting up backup directory...${NC}"
    if confirm "Create backup directory at $BACKUP_DIR?"; then
        mkdir -p "$BACKUP_DIR" || {
            echo -e "${RED}Error: Failed to create $BACKUP_DIR${NC}"
            exit 1
        }
        echo "Directory ready."
    else
        echo "Skipping backup directory setup."
        exit 1
    fi
}

backup_files() {
    echo -e "${GREEN}Step 2: Backing up WordPress files...${NC}"
    if confirm "Copy and zip files from $VVV_PATH/$SITE_NAME/public_html?"; then
        cd "$VVV_PATH/$SITE_NAME" || {
            echo -e "${RED}Error: Cannot access $VVV_PATH/$SITE_NAME${NC}"
            exit 1
        }
        cp -r public_html "$BACKUP_DIR/public_html" || {
            echo -e "${RED}Error: Failed to copy files${NC}"
            exit 1
        }
        cd "$BACKUP_DIR" || exit 1
        zip -r "${SITE_NAME}_files_${TIMESTAMP}.zip" public_html || {
            echo -e "${RED}Error: Failed to zip files${NC}"
            exit 1
        }
        echo "Files backed up: $BACKUP_DIR/${SITE_NAME}_files_${TIMESTAMP}.zip"
    else
        echo "Skipping file backup."
        exit 1
    fi
}

backup_database() {
    echo -e "${GREEN}Step 3: Backing up database...${NC}"
    if confirm "Export database $DB_NAME from VVV VM?"; then
        cd "$VVV_ROOT" || {
            echo -e "${RED}Error: Cannot access $VVV_ROOT${NC}"
            exit 1
        }
        vagrant ssh -c "mysqldump -u $MYSQL_USER -p$MYSQL_PASS $DB_NAME > /srv/www/$SITE_NAME/${SITE_NAME}_backup_${TIMESTAMP}.sql" || {
            echo -e "${RED}Error: Failed to export database. Ensure Vagrant is running in $VVV_ROOT.${NC}"
            exit 1
        }
        echo "Database exported on VM."
    else
        echo "Skipping database export."
        exit 1
    fi
}

retrieve_database() {
    echo -e "${GREEN}Step 4: Retrieving database backup...${NC}"
    if confirm "Copy database backup from VM to $BACKUP_DIR?"; then
        cd "$VVV_ROOT" || {
            echo -e "${RED}Error: Cannot access $VVV_ROOT${NC}"
            exit 1
        }
        scp -P "$VVV_PORT" -i "$VVV_KEY" -o StrictHostKeyChecking=no "vagrant@$VVV_IP:/srv/www/$SITE_NAME/${SITE_NAME}_backup_${TIMESTAMP}.sql" "$BACKUP_DIR/" || {
            echo -e "${RED}Error: Failed to copy database backup. Check IP ($VVV_IP), port ($VVV_PORT), and key ($VVV_KEY).${NC}"
            exit 1
        }
        echo "Database retrieved: $BACKUP_DIR/${SITE_NAME}_backup_${TIMESTAMP}.sql"
    else
        echo "Skipping database retrieval."
        exit 1
    fi
}

verify_backup() {
    echo -e "${GREEN}Step 5: Verifying backup...${NC}"
    if [ -f "$BACKUP_DIR/${SITE_NAME}_files_${TIMESTAMP}.zip" ] && [ -f "$BACKUP_DIR/${SITE_NAME}_backup_${TIMESTAMP}.sql" ]; then
        echo -e "${GREEN}Backup completed successfully!${NC}"
        echo "Files ZIP: $BACKUP_DIR/${SITE_NAME}_files_${TIMESTAMP}.zip"
        echo "Files Folder: $BACKUP_DIR/public_html"
        echo "Database: $BACKUP_DIR/${SITE_NAME}_backup_${TIMESTAMP}.sql"
        echo "Note: Original files and SQL file on VM are preserved."
        echo "Ready to migrate to production server."
    else
        echo -e "${RED}Error: Backup incomplete. Check files in $BACKUP_DIR${NC}"
        exit 1
    fi
}

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
