@description('Deployment Location')
param location string

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

@description('Name of Kubernetes Resource')
param aksName string = 'ddc-storage-${take(uniqueString(resourceGroup().id), 6)}'

@description('Number of Kubernetes Nodes')
param agentPoolCount int = 3
param agentPoolName string = 'k8agent'
param vmSize string = 'Standard_L16s_v2'
param hostname string = 'deploy1.ddc-storage.gaming.azure.com'

@description('Enable to configure certificate. Default: true')
param enableCert bool = true

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
param storageAccountName string = 'ddc${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
param storageResourceGroupName string = resourceGroup().name

@allowed([
  'new'
  'existing'
])
param newOrExistingKeyVault string = 'new'
param keyVaultName string = take('ddcKeyVault${uniqueString(resourceGroup().id, subscription().subscriptionId, location)}', 24)

@allowed([
  'new'
  'existing'
])
param newOrExistingPublicIp string = 'new'
param publicIpName string = 'ddcPublicIP${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@allowed([
  'new'
  'existing'
])
param newOrExistingTrafficManager string = 'new'
param trafficManagerName string = 'ddcPublicIP${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
@description('Relative DNS name for the traffic manager profile, must be globally unique.')
param trafficManagerDnsName string = 'tmp-${uniqueString(resourceGroup().id, subscription().id)}'

@allowed([
  'new'
  'existing'
])
param newOrExistingCosmosDB string = 'new'
param cosmosDBName string = 'ddc-db-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
param cosmosDBRG string = resourceGroup().name

param servicePrincipalClientID string = ''
param workerServicePrincipalClientID string

@secure()
param workerServicePrincipalSecret string = ''

@description('Name of Certificate (Default certificate is self-signed)')
param certificateName string = 'unreal-cloud-ddc-cert'

@description('Set to true to agree to the terms and conditions of the Epic Games EULA found here: https://store.epicgames.com/en-US/eula')
param epicEULA bool = false

@description('Active Directory Tennat ID')
param azureTenantID string = subscription().tenantId
param keyVaultTenantID string = azureTenantID
param loginTenantID string = azureTenantID

param namespace string = 'defaultnamespace'

@description('Delete old ref records no longer in use across the entire system')
param CleanOldRefRecords bool = true

@description('Delete old blobs that are no longer referenced by any ref - this runs in each region to cleanup that regions blob stores')
param CleanOldBlobs bool = true

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

module deployResources 'modules/resources.bicep' = if (epicEULA) {
  name: guid(keyVaultName, publicIpName, cosmosDBName, storageAccountName)
  params: {
    location: location
    newOrExistingKubernetes: newOrExistingKubernetes
    newOrExistingKeyVault: newOrExistingKeyVault
    newOrExistingPublicIp: newOrExistingPublicIp
    newOrExistingStorageAccount: newOrExistingStorageAccount
    newOrExistingTrafficManager: newOrExistingTrafficManager
    kubernetesParams: {
      name: '${aksName}-${take(location, 8)}'
      agentPoolCount: agentPoolCount
      agentPoolName: agentPoolName
      vmSize: vmSize
      clusterUserName: 'id-${aksName}-${location}'
    }
    secondaryLocations: secondaryLocations
    keyVaultName: take('${location}-${keyVaultName}', 24)
    publicIpName: '${publicIpName}-${location}'
    trafficManagerName: trafficManagerName
    trafficManagerDnsName: trafficManagerDnsName
    storageAccountName: '${take(location, 8)}${storageAccountName}'
    storageResourceGroupName: storageResourceGroupName
    storageSecretName: 'ddc-storage-connection-string'
    assignRole: assignRole
    isZoneRedundant: isZoneRedundant
    subject: 'system:serviceaccount:ddc-tests:workload-identity-sa'
  }
}

module secondaryResources 'modules/resources.bicep' = [for location in secondaryLocations: if (epicEULA) {
  name: guid(keyVaultName, publicIpName, storageAccountName, location)
  params: {
    location: location
    newOrExistingKubernetes: newOrExistingKubernetes
    newOrExistingKeyVault: newOrExistingKeyVault
    newOrExistingPublicIp: newOrExistingPublicIp
    newOrExistingStorageAccount: newOrExistingStorageAccount
    kubernetesParams: {
      name: '${aksName}-${take(location, 8)}'
      agentPoolCount: agentPoolCount
      agentPoolName: agentPoolName
      vmSize: vmSize
      clusterUserName: 'id-${aksName}-${location}'
    }
    keyVaultName: take('${location}-${keyVaultName}', 24)
    publicIpName: '${publicIpName}-${location}'
    storageAccountName: '${take(location, 8)}${storageAccountName}'
    storageResourceGroupName: storageResourceGroupName
    storageSecretName: 'ddc-storage-connection-string'
    assignRole: assignRole
    isZoneRedundant: isZoneRedundant
    subject: 'system:serviceaccount:ddc-tests:workload-identity-sa'
  }
}]

module kvCert 'modules/keyvault/create-kv-certificate.bicep' = [for location in union([ location ], secondaryLocations): if (assignRole && enableCert) {
  name: 'akvCert-${location}'
  dependsOn: [
    deployResources
    secondaryResources
  ]
  params: {
    akvName: take('${location}-${keyVaultName}', 24)
    location: location
    certificateName: certificateName
    certificateCommonName: hostname
    issuerName: certificateIssuer
    issuerProvider: issuerProvider
    useExistingManagedIdentity: newOrExistingStorageAccount == 'new' ? true : false
    managedIdentityName: 'id-${aksName}-${location}'
    rbacRolesNeededOnKV: '00482a5a-887f-4fb3-b363-3b7fe8e74483' // Key Vault Admin
  }
}]

module buildApp 'modules/keyvault/vaults/secrets.bicep' = [for location in union([ location ], secondaryLocations): if (assignRole && epicEULA && workerServicePrincipalSecret != '') {
  name: 'build-app-${location}-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
  dependsOn: [
    deployResources
    secondaryResources
  ]
  params: {
    keyVaultName: take('${location}-${keyVaultName}', 24)
    secretName: 'build-app-secret'
    secretValue: workerServicePrincipalSecret
  }
}]

module cosmosDB 'modules/documentDB/databaseAccounts.bicep' = {
  name: 'cosmosDB-${uniqueString(location, resourceGroup().id, deployment().name)}-key'
  dependsOn: [
    deployResources
    secondaryResources
  ]
  params: {
    location: location
    secondaryLocations: secondaryLocations
    name: cosmosDBName
    newOrExisting: newOrExistingCosmosDB
    cosmosDBRG: cosmosDBRG
  }
}

module cassandraKeys 'modules/keyvault/vaults/secrets.bicep' = [for location in union([ location ], secondaryLocations): if (assignRole && epicEULA) {
  name: 'cassandra-keys-${location}-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'
  dependsOn: [
    cosmosDB
  ]
  params: {
    keyVaultName: take('${location}-${keyVaultName}', 24)
    secretName: 'ddc-db-connection-string'
    secretValue: cosmosDB.outputs.cassandraConnectionString
  }
}]

module setuplocations 'modules/ddc-setup-locations.bicep' = if (assignRole && epicEULA) {
  name: 'setup-ddc-${location}'
  dependsOn: [
    cassandraKeys
  ]
  params: {
    aksName: aksName
    location: location
    secondaryLocations: secondaryLocations
    resourceGroupName: resourceGroup().name
    publicIpName: publicIpName
    keyVaultName: keyVaultName
    servicePrincipalClientID: servicePrincipalClientID
    workerServicePrincipalClientID: workerServicePrincipalClientID
    hostname: hostname
    azureTenantID: azureTenantID
    keyVaultTenantID: keyVaultTenantID
    loginTenantID: loginTenantID
    namespace: namespace
    CleanOldRefRecords: CleanOldRefRecords
    CleanOldBlobs: CleanOldBlobs
  }
}

output _artifactsLocation string = _artifactsLocation
output _artifactsLocationWithToken bool = _artifactsLocationWithToken
output cosmosDBName string = cosmosDBName
output newOrExistingCosmosDB string = newOrExistingCosmosDB
