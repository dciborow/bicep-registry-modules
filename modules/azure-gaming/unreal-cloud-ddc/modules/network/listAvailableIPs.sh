#!/bin/bash
set -e

echo "Finding free IPs in vnet $VNET_NAME, subnet $SUBNET_NAME, resource group $RESOURCE_GROUP"
freeIPArrayString="$(az network vnet subnet list-available-ips --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" -n "$SUBNET_NAME")"
resultsJsonString="{ \"availableIPs\": $freeIPArrayString }"
echo $resultsJsonString > $AZ_SCRIPTS_OUTPUT_PATH
