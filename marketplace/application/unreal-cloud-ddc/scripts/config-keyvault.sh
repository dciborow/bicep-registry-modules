#!/bin/bash
# -------------------------------------------------------------
#  Copyright (c) Microsoft Corporation. All rights reserved.
# -------------------------------------------------------------
# 
# This script configures the Key Vault for the Azure Storage account.
# -------------------------------------------------------------
# PARAMETERS
# -------------------------------------------------------------
# KEYVAULT_NAME : Name of the Key Vault
# RESOURCE_GROUP: Resourece Group Name
# APP_ID        : Azure App ID for Federated Credential
# -------------------------------------------------------------
RESOURCE_GROUP=$1
APP_ID=$2


SUBSCRIPTION_ID=$(
az account show \
    --query "id" \
    --output tsv
)
MY_ID=$(
az ad signed-in-user show \
    --query "id" \
    --output tsv
)

KEY_VAULTS=$(az keyvault list -g "$RESOURCE_GROUP" --query [].[name] --output tsv)
for KEYVAULT_NAME in $KEY_VAULTS; do
    echo "##[section] Set values for Resource Group: $RESOURCE_GROUP and Key Vault: $KEYVAULT_NAME"
    ADMIN_ROLE="Key Vault Administrator"
    echo "##[debug] Grant Key Vault access to self"
    az role assignment create \
        --role "$ADMIN_ROLE" \
        --assignee "$MY_ID" \
        --scope "/subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEYVAULT_NAME" \
        > /dev/null || exit 1

    echo "##[debug] Grant Key Vault access to Service Principal"
    az role assignment create \
        --role "$ADMIN_ROLE" \
        --assignee "$APP_ID" \
        --scope "/subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEYVAULT_NAME" \
        > /dev/null || exit 1

    SECRET=$(
    az ad app credential reset \
        --display-name "unreal-cloud-ddc" \
        --id "$APP_ID" \
        --append \
        --only-show-errors \
        --query "password" \
        --output tsv \
        || exit 1
    )

    echo "##[debug] Create secrets in Key Vault"
    az keyvault secret set \
        --vault-name "$KEYVAULT_NAME" \
        --name "ucddc-client-app-secret" \
        --value "$SECRET" \
        > /dev/null 2>&1 || exit

    az keyvault secret set \
        --vault-name "$KEYVAULT_NAME" \
        --name "build-app-secret" \
        --value "$SECRET" \
        > /dev/null || exit 1

done

echo "##[debug] Complete"
