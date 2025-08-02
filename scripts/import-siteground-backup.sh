#!/bin/bash

# VVV SiteGround Backup Import Script
# This script clones an existing VVV site and imports a SiteGround backup
# 
# Usage: ./import-siteground-backup.sh <source_site> <new_site_name> <backup_file> <original_domain>
# 
# Requirements:
#   - Must be run from VVV root directory
#   - Valid SiteGround backup .tar.gz file
#   - VVV environment with running Vagrant box
# 
# Example: ./import-siteground-backup.sh wordpress-one mystore backup.tar.gz https://example.com

set -e  # Exit on any error
cooocc
# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if we're in VVV directory
check_vvv_directory() {
    if [[ ! -f "Vagrantfile" ]] || [[ ! -d "www" ]] || [[ ! -d "config" ]]; then
        print_error "This script must be run from the VVV root directory"
        exit 1
    fi
}

# Function to validate inputs
validate_inputs() {
    if [[ $# -ne 4 ]]; then
        print_error "Usage: $0 <source_site> <new_site_name> <backup_file> <original_domain>"
        print_error "Example: $0 wordpress-one mysite backup.tar.gz https://example.com"
        exit 1
    fi

    SOURCE_SITE="$1"
    NEW_SITE="$2"
    BACKUP_FILE="$3"
    ORIGINAL_DOMAIN="$4"

    # Check if source site exists
    if [[ ! -d "www/$SOURCE_SITE" ]]; then
        print_error "Source site 'www/$SOURCE_SITE' does not exist"
        exit 1
    fi

    # Check if backup file exists
    if [[ ! -f "$BACKUP_FILE" ]]; then
        print_error "Backup file '$BACKUP_FILE' does not exist"
        exit 1
    fi

    # Check if new site already exists
    if [[ -d "www/$NEW_SITE" ]]; then
        print_error "Site 'www/$NEW_SITE' already exists"
        exit 1
    fi

    # Validate domain format
    if [[ ! "$ORIGINAL_DOMAIN" =~ ^https?:// ]]; then
        print_error "Original domain must include protocol (http:// or https://)"
        exit 1
    fi
}

# Function to clone the source site
clone_site() {
    print_status "Cloning $SOURCE_SITE to $NEW_SITE..."
    cp -r "www/$SOURCE_SITE" "www/$NEW_SITE"
    print_success "Site cloned successfully"
}

# Function to extract and import SiteGround backup
import_backup() {
    print_status "Extracting SiteGround backup..."
    
    # Move backup to new site directory
    cp "$BACKUP_FILE" "www/$NEW_SITE/"
    cd "www/$NEW_SITE"
    
    # Extract backup
    tar -xzf "$(basename "$BACKUP_FILE")"
    
    # Find the WordPress files in the SiteGround structure
    SITEGROUND_PATH=$(find . -name "public_html" -type d | head -1)
    if [[ -z "$SITEGROUND_PATH" ]]; then
        print_error "Could not find public_html directory in backup"
        exit 1
    fi
    
    print_status "Found WordPress files at: $SITEGROUND_PATH"
    
    # Replace existing public_html with backup files
    rm -rf public_html
    cp -r "$SITEGROUND_PATH" ./
    
    # Remove the original wp-config.php so VVV can create a new one
    if [[ -f "public_html/wp-config.php" ]]; then
        rm "public_html/wp-config.php"
        print_status "Removed original wp-config.php for VVV setup"
    fi
    
    cd ../..
    print_success "Backup files imported successfully"
}

# Function to update VVV config
update_vvv_config() {
    print_status "Updating VVV configuration..."
    
    # Create backup of config
    cp "config/config.yml" "config/config.yml.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Find the sites section and add new site configuration
    local config_file="config/config.yml"
    local temp_file=$(mktemp)
    
    # Check if sites section exists
    if ! grep -q "^sites:" "$config_file"; then
        print_error "Could not find 'sites:' section in config.yml"
        exit 1
    fi
    
    # Find where to insert the new site (after sites: line but before next top-level section)
    local sites_line=$(grep -n "^sites:" "$config_file" | cut -d: -f1)
    local next_section_line=$(tail -n +$((sites_line + 1)) "$config_file" | grep -n "^[a-zA-Z]" | head -1 | cut -d: -f1)
    
    if [[ -n "$next_section_line" ]]; then
        # Insert before next section
        local insert_line=$((sites_line + next_section_line - 1))
    else
        # Insert at end of file
        local insert_line=$(wc -l < "$config_file")
        insert_line=$((insert_line + 1))
    fi
    
    # Create the new site configuration
    cat > "$temp_file" << EOF

  $NEW_SITE:
    skip_provisioning: false
    description: "Site imported from SiteGround backup"
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template.git
    hosts:
      - $NEW_SITE.test
    custom:
      wpconfig_constants:
        WP_DEBUG: true
        WP_DEBUG_LOG: true
        WP_DISABLE_FATAL_ERROR_HANDLER: true
EOF
    
    # Insert the new site configuration into the config file
    {
        head -n $((insert_line - 1)) "$config_file"
        cat "$temp_file"
        tail -n +$insert_line "$config_file"
    } > "${config_file}.tmp"
    
    # Replace original with updated config
    mv "${config_file}.tmp" "$config_file"
    rm -f "$temp_file"
    
    print_success "VVV configuration updated"
}

# Function to provision the site
provision_site() {
    print_status "Provisioning $NEW_SITE..."
    
    if vagrant provision --provision-with "site-$NEW_SITE"; then
        print_success "Site provisioned successfully"
    else
        print_error "Site provisioning failed"
        exit 1
    fi
}

# Function to import database
import_database() {
    print_status "Looking for database backup..."
    
    cd "www/$NEW_SITE"
    
    # Find MySQL backup in the extracted files
    DB_FILE=$(find . -name "*.gz" -path "*/mysql/*" | head -1)
    
    if [[ -z "$DB_FILE" ]]; then
        print_warning "No database backup found in mysql directory"
        print_warning "Site created with fresh WordPress installation"
        cd ../..
        return 0
    fi
    
    print_status "Found database backup: $DB_FILE"
    
    # Extract database file
    gunzip "$DB_FILE"
    DB_FILE_UNCOMPRESSED="${DB_FILE%.gz}"
    
    # Fix collation issues for compatibility
    print_status "Fixing database collation compatibility..."
    sed -i 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' "$DB_FILE_UNCOMPRESSED"
    
    cd ../..
    
    # Reset and import database
    print_status "Resetting database..."
    vagrant ssh -c "wp --path=/srv/www/$NEW_SITE/public_html db reset --yes" || {
        print_error "Failed to reset database"
        exit 1
    }
    
    print_status "Importing database backup..."
    vagrant ssh -c "wp --path=/srv/www/$NEW_SITE/public_html db import /srv/www/$NEW_SITE/$DB_FILE_UNCOMPRESSED" || {
        print_error "Failed to import database"
        exit 1
    }
    
    print_success "Database imported successfully"
}

# Function to update URLs in database
update_database_urls() {
    print_status "Updating URLs in database..."
    
    # Remove protocol and trailing slash from original domain for search
    CLEAN_DOMAIN=$(echo "$ORIGINAL_DOMAIN" | sed 's|^https\?://||' | sed 's|/$||')
    LOCAL_URL="http://$NEW_SITE.test"
    
    print_status "Replacing $ORIGINAL_DOMAIN with $LOCAL_URL"
    
    # Perform search and replace
    vagrant ssh -c "wp --path=/srv/www/$NEW_SITE/public_html search-replace '$ORIGINAL_DOMAIN' '$LOCAL_URL'" || {
        print_warning "URL replacement may have failed, but continuing..."
    }
    
    print_success "URLs updated for local development"
}

# Function to clean up temporary files
cleanup() {
    print_status "Cleaning up temporary files..."
    
    cd "www/$NEW_SITE"
    
    # Remove backup archive
    rm -f "$(basename "$BACKUP_FILE")"
    
    # Remove extracted backup structure (keep only public_html)
    find . -maxdepth 1 -type d -name "mnt" -exec rm -rf {} + 2>/dev/null || true
    
    cd ../..
    
    print_success "Cleanup completed"
}

# Function to display final information
show_completion_info() {
    print_success "==================================="
    print_success "IMPORT COMPLETED SUCCESSFULLY!"
    print_success "==================================="
    echo ""
    print_status "Site Details:"
    echo "  • Site Name: $NEW_SITE"
    echo "  • Local URL: http://$NEW_SITE.test"
    echo "  • Site Path: www/$NEW_SITE/"
    echo ""
    print_status "Next Steps:"
    echo "  1. Visit http://$NEW_SITE.test in your browser"
    echo "  2. Check that the site loads correctly"
    echo "  3. Update any necessary plugin/theme settings"
    echo "  4. Test functionality specific to your site"
    echo ""
    print_warning "Note: You may need to:"
    echo "  • Reconfigure plugins that use external APIs"
    echo "  • Update payment gateway settings"
    echo "  • Adjust any domain-specific configurations"
}

# Main execution
main() {
    print_status "VVV SiteGround Backup Import Script"
    print_status "===================================="
    
    check_vvv_directory
    validate_inputs "$@"
    
    print_status "Starting import process..."
    print_status "Source site: $SOURCE_SITE"
    print_status "New site: $NEW_SITE"
    print_status "Backup file: $BACKUP_FILE"
    print_status "Original domain: $ORIGINAL_DOMAIN"
    echo ""
    
    clone_site
    import_backup
    update_vvv_config
    provision_site
    import_database
    update_database_urls
    cleanup
    show_completion_info
}

# Run main function with all arguments
main "$@"