#!/bin/bash

# Script to help find Microsoft Fabric Workspace Service Principal Object ID
# Usage: ./scripts/find-workspace-sp.sh "Your Fabric Workspace Name"

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"Your Fabric Workspace Name\""
    echo "Example: $0 \"My Fabric Workspace\""
    exit 1
fi

WORKSPACE_NAME="$1"

echo "Looking up Service Principal for Fabric Workspace: $WORKSPACE_NAME"
echo "======================================================="

# Check if Azure CLI is logged in
if ! az account show > /dev/null 2>&1; then
    echo "Error: Not logged in to Azure CLI. Please run 'az login' first."
    exit 1
fi

# Search for the service principal
echo "Searching for service principal..."
SP_INFO=$(az ad sp list --display-name "$WORKSPACE_NAME" --query "[0].{objectId:id,appId:appId,displayName:displayName}" -o json 2>/dev/null)

if [ "$SP_INFO" = "null" ] || [ -z "$SP_INFO" ]; then
    echo "❌ Service Principal not found for workspace: $WORKSPACE_NAME"
    echo ""
    echo "Possible reasons:"
    echo "1. The workspace name is incorrect"
    echo "2. The workspace hasn't been created yet"
    echo "3. You don't have permissions to view the service principal"
    echo ""
    echo "To find all available workspaces, try:"
    echo "az ad sp list --query \"[?contains(displayName, 'Fabric')].{displayName:displayName,objectId:id}\" -o table"
    exit 1
fi

OBJECT_ID=$(echo "$SP_INFO" | jq -r '.objectId')
APP_ID=$(echo "$SP_INFO" | jq -r '.appId')
DISPLAY_NAME=$(echo "$SP_INFO" | jq -r '.displayName')

echo "✅ Found Service Principal:"
echo "   Display Name: $DISPLAY_NAME"
echo "   Object ID: $OBJECT_ID"
echo "   App ID: $APP_ID"
echo ""
echo "📋 Add this to your .env file:"
echo "AZURE_FABRIC_WORKSPACE_NAME=\"$WORKSPACE_NAME\""
echo "AZURE_FABRIC_WORKSPACE_OBJECT_ID=\"$OBJECT_ID\""