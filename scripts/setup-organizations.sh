#!/bin/bash

# Grafana Multi-Tenant Setup Script
# ==================================
# This script creates organizations and users for multi-tenant Grafana setup.
# Run this after deploying Grafana to Railway.

# Configuration - UPDATE THESE VALUES
GRAFANA_URL="${GRAFANA_URL:-https://your-grafana.railway.app}"
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}================================${NC}"
echo -e "${YELLOW}Grafana Multi-Tenant Setup${NC}"
echo -e "${YELLOW}================================${NC}"
echo ""
echo "Grafana URL: $GRAFANA_URL"
echo "Admin User: $ADMIN_USER"
echo ""

# Check if Grafana is accessible
echo -e "${YELLOW}Checking Grafana connectivity...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$GRAFANA_URL/api/health")
if [ "$HTTP_CODE" != "200" ]; then
    echo -e "${RED}Error: Cannot connect to Grafana at $GRAFANA_URL${NC}"
    echo "HTTP Status: $HTTP_CODE"
    exit 1
fi
echo -e "${GREEN}Grafana is accessible!${NC}"
echo ""

# Function to create organization
create_org() {
    local org_name=$1
    echo -e "${YELLOW}Creating organization: $org_name${NC}"

    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -u "$ADMIN_USER:$ADMIN_PASSWORD" \
        "$GRAFANA_URL/api/orgs" \
        -d "{\"name\":\"$org_name\"}")

    org_id=$(echo $response | grep -o '"orgId":[0-9]*' | grep -o '[0-9]*')

    if [ -n "$org_id" ]; then
        echo -e "${GREEN}Created organization '$org_name' with ID: $org_id${NC}"
        echo $org_id
    else
        echo -e "${RED}Failed to create organization: $response${NC}"
        echo ""
    fi
}

# Function to create user
create_user() {
    local name=$1
    local login=$2
    local password=$3
    local org_id=$4

    echo -e "${YELLOW}Creating user: $login${NC}"

    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -u "$ADMIN_USER:$ADMIN_PASSWORD" \
        "$GRAFANA_URL/api/admin/users" \
        -d "{
            \"name\": \"$name\",
            \"login\": \"$login\",
            \"password\": \"$password\",
            \"OrgId\": $org_id
        }")

    user_id=$(echo $response | grep -o '"id":[0-9]*' | grep -o '[0-9]*')

    if [ -n "$user_id" ]; then
        echo -e "${GREEN}Created user '$login' with ID: $user_id in Org: $org_id${NC}"
    else
        echo -e "${RED}Failed to create user: $response${NC}"
    fi
}

# Create Organizations
echo ""
echo -e "${YELLOW}Step 1: Creating Organizations${NC}"
echo "-------------------------------"

ORG_A_ID=$(create_org "Project A")
ORG_B_ID=$(create_org "Project B")
ORG_C_ID=$(create_org "Project C")

# Create Users (if org creation was successful)
echo ""
echo -e "${YELLOW}Step 2: Creating Users${NC}"
echo "----------------------"

if [ -n "$ORG_A_ID" ]; then
    create_user "Project A Admin" "projecta_admin" "change-me-projecta" "$ORG_A_ID"
fi

if [ -n "$ORG_B_ID" ]; then
    create_user "Project B Admin" "projectb_admin" "change-me-projectb" "$ORG_B_ID"
fi

if [ -n "$ORG_C_ID" ]; then
    create_user "Project C Admin" "projectc_admin" "change-me-projectc" "$ORG_C_ID"
fi

# Summary
echo ""
echo -e "${YELLOW}================================${NC}"
echo -e "${YELLOW}Setup Complete!${NC}"
echo -e "${YELLOW}================================${NC}"
echo ""
echo "Organizations created:"
echo "  - Project A (Org ID: ${ORG_A_ID:-'failed'})"
echo "  - Project B (Org ID: ${ORG_B_ID:-'failed'})"
echo "  - Project C (Org ID: ${ORG_C_ID:-'failed'})"
echo ""
echo "Users created (CHANGE PASSWORDS!):"
echo "  - projecta_admin / change-me-projecta"
echo "  - projectb_admin / change-me-projectb"
echo "  - projectc_admin / change-me-projectc"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Login to Grafana as superadmin"
echo "2. Switch to each organization"
echo "3. Add PostgreSQL data source for each org"
echo "4. Import dashboard templates"
echo "5. Update user passwords"
echo ""
echo "Update redirect service with these Org IDs:"
echo "  projecta -> orgId: ${ORG_A_ID:-2}"
echo "  projectb -> orgId: ${ORG_B_ID:-3}"
echo "  projectc -> orgId: ${ORG_C_ID:-4}"
