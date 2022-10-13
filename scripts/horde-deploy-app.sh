#!/bin/bash
# The following variables must be set before running this script.
#
# CLUSTER_NAME: AKS Cluster Name
# RESOURCE_GROUP: Resourece Group Name
# MANAGED_RESOURCE_GROUP: Managed Resourece Group Name
# LOCATION: Azure Region for deployment
# AGENT_POOL_COUNT: Number of AKS Nodes
# OBJECT_ID: Azure Object ID for Federated Credential 
MY_CLUSTER=$1
RESOURCE_GROUP=$2
LOCATION=$3

echo '##[section]Horde Storage - Deploy Bicep Template'
az group create \
    --name $RESOURCE_GROUP\
    --location $LOCATION
az deployment group create \
    --name $RESOURCE_GROUP \
    --template-file main.bicep \
    --parameters main.parameters.json \
    --resource-group $RESOURCE_GROUP 
    --managed-resource-group $MANAGED_RESOURCE_GROUP || exit 1

RESOURCE_GROUP=$MANAGED_RESOURCE_GROUP
