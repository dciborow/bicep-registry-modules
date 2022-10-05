@description('Deployment Location')
param location string = resourceGroup().location

@description('Secondary Deployment Locations')
param secondaryLocations array = []

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''
@allowed([
  'new'
  'existing'
])
param newOrExistingKubernetes string = 'new'
param aksName string = 'horde-storage-${take(uniqueString(resourceGroup().id), 6)}'
param agentPoolCount int = 3
param agentPoolName string = 'k8agent'
param vmSize string = 'Standard_L16s_v2'
param hostname string = 'deploy1.horde-storage.gaming.azure.com'

@description('Unknown, Self, or {IssuerName} for certificate signing')
param certificateIssuer string = 'Self'

@description('Certificate Issuer Provider')
param issuerProvider string = ''

@description('Running this template requires roleAssignment permission on the Resource Group, which require an Owner role. Set this to false to deploy some of the resources')
param assignRole bool = true

@description('Enable Zonal Redunancy for supported regions')
param isZoneRedundant bool = true

@allowed([
  'new'
  'existing'
])
param newOrExistingStorageAccount string = 'new'
param storageAccountName string = 'horde${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@allowed([
  'new'
  'existing'
])
param newOrExistingKeyVault string = 'new'
param keyVaultName string = take('hordeKeyVault${uniqueString(resourceGroup().id, subscription().subscriptionId, location)}', 24)

@allowed([
  'new'
  'existing'
])
param newOrExistingPublicIp string = 'new'
param publicIpName string = 'hordePublicIP${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@allowed([
  'new'
  'existing'
])
param newOrExistingTrafficManager string = 'new'
param trafficManagerName string = 'hordePublicIP${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
@description('Relative DNS name for the traffic manager profile, must be globally unique.')
param trafficManagerDnsName string = 'tmp-${uniqueString(resourceGroup().id, subscription().id)}'

@allowed([
  'new'
  'existing'
])
param newOrExistingCosmosDB string = 'new'
param cosmosDBName string = 'hordeDB-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

param servicePrincipalObjectID string = ''

param servicePrincipalClientID string = ''

@secure()
param servicePrincipalSecret string = ''

@description('Name of Certificate (Default certificate is self-signed)')
param certificateName string = 'horde-storage-cert'

@description('Set to true to agree to the terms and conditions of the Epic Games EULA found here: https://store.epicgames.com/en-US/eula')
param epicEULA bool = false

var _artifactsLocationWithToken = _artifactsLocationSasToken != ''

resource partnercenter 'Microsoft.Resources/deployments@2021-04-01' = {
  name: 'pid-7837dd60-4ba8-419a-a26f-237bbe170773-partnercenter'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

module deployResources '../../bicep-templates/resources.bicep' = if(epicEULA) {
  name: guid(keyVaultName, publicIpName, cosmosDBName, storageAccountName)
  params: {
    location: location
    newOrExistingKubernetes: newOrExistingKubernetes
    newOrExistingCosmosDB: newOrExistingCosmosDB
    newOrExistingKeyVault: newOrExistingKeyVault
    newOrExistingPublicIp: newOrExistingPublicIp
    newOrExistingStorageAccount: newOrExistingStorageAccount
    newOrExistingTrafficManager: newOrExistingTrafficManager
    kubernetesParams: {
      name: '${aksName}-${take(location, 8)}'
      agentPoolCount: agentPoolCount
      agentPoolName: agentPoolName
      vmSize: vmSize
    }
    cosmosDBName: cosmosDBName
    secondaryLocations: secondaryLocations
    keyVaultName: take('${location}-${keyVaultName}', 24)
    publicIpName: '${publicIpName}-${location}'
    trafficManagerName: trafficManagerName
    trafficManagerDnsName: trafficManagerDnsName
    storageAccountName: '${take(location, 8)}${storageAccountName}'
    storageSecretName: 'horde-storage-${location}-connection-string'
    cassandraSecretName: 'horde-db-connection-string'
    assignRole: assignRole
    isZoneRedundant: isZoneRedundant
  }
}

module secondaryResources '../../bicep-templates/resources.bicep' = [for hordeLocation in secondaryLocations: if(epicEULA) {
  name: guid(keyVaultName, publicIpName, storageAccountName, hordeLocation)
  params: {
    location: hordeLocation
    newOrExistingKubernetes: newOrExistingKubernetes
    newOrExistingKeyVault: newOrExistingKeyVault
    newOrExistingPublicIp: newOrExistingPublicIp
    newOrExistingStorageAccount: newOrExistingStorageAccount
    kubernetesParams: {
      name: '${aksName}-${take(hordeLocation, 8)}'
      agentPoolCount: agentPoolCount
      agentPoolName: agentPoolName
      vmSize: vmSize
    }
    keyVaultName: take('${hordeLocation}-${keyVaultName}', 24)
    publicIpName: '${publicIpName}-${hordeLocation}'
    storageAccountName: '${take(hordeLocation, 8)}${storageAccountName}'
    storageSecretName: 'horde-storage-${hordeLocation}-connection-string'
    assignRole: assignRole
    isZoneRedundant: isZoneRedundant
  }
}]

module kvCert '../../bicep-templates/keyvault/create-kv-certificate.bicep' = [for hordeLocation in union([ location ], secondaryLocations): if (assignRole) {
  name: 'akvCert-${hordeLocation}'
  dependsOn: [
    deployResources
    secondaryResources
  ]
  params: {
    akvName: take('${hordeLocation}-${keyVaultName}', 24)
    location: hordeLocation
    certificateName: certificateName
    certificateCommonName: hostname
    issuerName: certificateIssuer
    issuerProvider: issuerProvider
  }
}]

module hordeClientApp '../..//bicep-templates/keyvault/vaults/secrets.bicep' = [for hordeLocation in union([ location ], secondaryLocations): if (assignRole && epicEULA && servicePrincipalSecret != '') {
  name: 'sp-secrets-${hordeLocation}-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
  dependsOn: [
    deployResources
    secondaryResources
  ]
  params: {
    keyVaultName: take('${hordeLocation}-${keyVaultName}', 24)
    secretName: 'horde-client-app-secret'
    secretValue: servicePrincipalSecret
  }
}]

module buildApp '../..//bicep-templates/keyvault/vaults/secrets.bicep' = [for hordeLocation in union([ location ], secondaryLocations): if (assignRole && epicEULA && servicePrincipalSecret != '') {
  name: 'build-app-${hordeLocation}-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
  dependsOn: [
    deployResources
    secondaryResources
  ]
  params: {
    keyVaultName: take('${hordeLocation}-${keyVaultName}', 24)
    secretName: 'build-app-secret'
    secretValue: servicePrincipalSecret
  }
}]

module setupHordeLocations 'modules/horde-setup-locations.bicep' = if (assignRole && epicEULA) {
  name: 'setupHorde-${location}'
  dependsOn: [
    hordeClientApp
    buildApp
  ]
  params: {
    aksName: aksName
    location: location
    secondaryLocations: secondaryLocations
    resourceGroupName: resourceGroup().name
    publicIpName: publicIpName
    keyVaultName: keyVaultName
    servicePrincipalClientID: servicePrincipalClientID
    hostname: hostname
  }
}

output _artifactsLocation string = _artifactsLocation
output _artifactsLocationWithToken bool = _artifactsLocationWithToken
output cosmosDBName string = cosmosDBName
output newOrExistingCosmosDB string = newOrExistingCosmosDB
output servicePrincipalObjectID string = servicePrincipalObjectID
