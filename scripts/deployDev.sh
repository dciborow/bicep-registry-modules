#!/bin/bash
if [ -z "$resourceGroup" ]; then
    resourceGroup=$0
    storageAccount=$1
    artifactContainer=$2
    location=$4
    WORKING_DIR=$5
    PIXEL_STREAMING_SAS=$6
fi

suffix=$RANDOM
echo "::set-output name=suffix::$suffix"

cd "$WORKING_DIR" || exit

az group create \
    --name devops-test-$suffix \
    --location eastus

accountKey=$(az storage account keys list -g "$resourceGroup" -n "$storageAccount" | jq .[0].value)
outputUrl="https://$storageAccount.blob.core.windows.net/$artifactContainer/"

outputSas=$(az storage container generate-sas --only-show-errors --account-name "$storageAccount" --account-key "$accountKey" --name "$artifactContainer" --permissions dlrw --expiry 2022-12-01 -o tsv)
outputSas="?$outputSas"

az deployment group create \
    --name devops-test-$suffix \
    --resource-group devops-test-$suffix \
    --template-file mainTemplate.bicep \
    --parameters mainTemplate.parameters.json \
    --parameters basics_adminPass="$ADMIN_PASS" \
    --parameters _artifactsLocation="$outputUrl" \
    --parameters _artifactsLocationSasToken="$outputSas" \
    --parameters location="$location"
