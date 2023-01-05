#!/bin/bash
# The following variables must be set before running this script.
#
# RESOURCE_GROUP: Resourece Group Name
# LOCATION: Azure Region for deployment
# PARAMETERS: Input Parameters File
# OBJECT_ID: Azure Object ID for Federated Credential 
RESOURCE_GROUP=$1
LOCATION=$2
PARAMETERS=$3
TEMPLATE=$4

if [ -z "$PARAMETERS" ]; then
    PARAMETERS="mainTemplate.parameters.json"
fi
if [ -z "$TEMPLATE" ]; then
    TEMPLATE="mainTemplate.bicep"
fi

echo '##[section]UC DDC Storage - Deploy Bicep Template'
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

az deployment group create \
    --name "$RESOURCE_GROUP" \
    --template-file $TEMPLATE \
    --parameters $PARAMETERS \
    --resource-group "$RESOURCE_GROUP" || exit 1
