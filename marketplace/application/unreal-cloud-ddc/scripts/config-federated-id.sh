#!/bin/bash
# -------------------------------------------------------------
#  Copyright (c) Microsoft Corporation. All rights reserved.
# -------------------------------------------------------------
# 
# Configure a Federated Identity for the AKS cluster.
# -------------------------------------------------------------
# PARAMETERS
# -------------------------------------------------------------
# CLUSTER_NAME  : AKS Cluster Name
# RESOURCE_GROUP: Resourece Group Name
# OBJECT_ID     : Azure Object ID for Federated Credential 
# -------------------------------------------------------------
RESOURCE_GROUP=$1
OBJECT_ID=$2

CLUSTER_NAMES=$(az aks list -g "$RESOURCE_GROUP" --query [].[name] --output tsv)
for CLUSTER_NAME in $CLUSTER_NAMES; do
    echo '##[section] Unreal Cloud DDC - enable OIDC issuer'

    echo '##[command] az extension add --name aks-preview && az extension update --name aks-preview'
    az feature register \
        --only-show-errors \
        --name EnableOIDCIssuerPreview \
        --namespace Microsoft.ContainerService > /dev/null

    az provider register \
        --only-show-errors \
        --namespace Microsoft.ContainerService > /dev/null 2>&1 || exit 1

    az extension add \
        --only-show-errors \
        --name aks-preview \
    && az extension update \
        --only-show-errors \
        --name aks-preview \
        > /dev/null 2>&1 || exit 1

    echo "##[command] az aks update -n $CLUSTER_NAME -g $RESOURCE_GROUP --enable-oidc-issuer"
    az aks update \
        --only-show-errors \
        -n "$CLUSTER_NAME" \
        -g "$RESOURCE_GROUP" \
        --enable-oidc-issuer \
        > /dev/null 2>&1 || exit 1

    echo "##[command] ISSUER_URL=$(az aks show -n "$CLUSTER_NAME" -g "$RESOURCE_GROUP" --query 'oidcIssuerProfile.issuerUrl' -otsv)"
    ISSUER_URL=$(
    az aks show \
        --only-show-errors \
        -n "$CLUSTER_NAME" \
        -g "$RESOURCE_GROUP" \
        --query "oidcIssuerProfile.issuerUrl" -otsv
    )

    echo "##[debug] Create or Update Federated Identity"
    echo '{
        "name":"'"$CLUSTER_NAME"'",
        "issuer":"'"$ISSUER_URL"'",
        "subject":"system:serviceaccount:ucddc-tests:workload-identity-sa",
        "description":"For use by UC DDC Storage app on pipeline test cluster ",
        "audiences":["api://AzureADTokenExchange"]
    }' > parameters.json

    echo "##[command] az ad app federated-credential update --id $OBJECT_ID --federated-credential-id $CLUSTER_NAME --parameters parameters.json || az ad app federated-credential create"
    az ad app federated-credential update \
        --id "$OBJECT_ID" \
        --federated-credential-id "$CLUSTER_NAME" \
        --parameters parameters.json \
    || az ad app federated-credential create \
        --id "$OBJECT_ID" \
        --parameters parameters.json
done
