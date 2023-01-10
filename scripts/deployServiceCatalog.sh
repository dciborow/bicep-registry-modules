#!/bin/bash

if [ -z "$resourceGroup" ]; then
    resourceGroup=$0
    location=$1
fi

# Define and create a managed application

# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
appDefinitionResourceGroup=$resourceGroup
appResourceGroup="$resourceGroup-mrg"\ck\a
tag="create-uc-ddc"
managedApp="UnrealCloud-DDC"

az account show || exit 1

# Create definition for a managed application

# Create a application definition resource group
echo "Creating $appDefinitionResourceGroup in "$location"..."
az group create --name $appDefinitionResourceGroup --location "$location" --tags $tag || exit 1

# Get Azure Active Directory group to manage the application
groupid=$(az ad group show --group reader --query objectId --output tsv)

# Get role
roleid=$(az role definition list --name Owner --query [].name --output tsv)

az bicep build -f mainTemplate.bicep -o mainTemplate.json

# Create the definition for a managed application
az managedapp definition create \
    --name "$managedApp" \
    --location "$location" \
    --resource-group $appDefinitionResourceGroup \
    --lock-level ReadOnly \
    --display-name "Managed Storage Account" \
    --description "Managed Azure Storage Account" \
    --authorizations "$groupid:$roleid" \
    --create-ui-definition @createUIDefinition.json \
    --main-template @mainTemplate.json

# Create managed application

# Create application resource group
echo "Creating $appResourceGroup in "$location"..."
az group create --name $appResourceGroup --location "$location" --tags $tag || exit 1

# Get ID of managed application definition
appid=$(az managedapp definition show --name $managedApp --resource-group $appDefinitionResourceGroup --query id --output tsv)

# Get subscription ID
subid=$(az account show --query id --output tsv)

# Construct the ID of the managed resource group
managedGroupId=/subscriptions/$subid/resourceGroups/infrastructureGroup

# Create the managed application
az managedapp create \
    --name storageApp \
    --location "$location" \
    --kind "Servicecatalog" \
    --resource-group $appResourceGroup \
    --managedapp-definition-id $appid \
    --managed-rg-id $managedGroupId \
    --parameters @mainTemplate.parameters.json
