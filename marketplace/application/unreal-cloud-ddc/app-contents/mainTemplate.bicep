//  Parameters
@description('Deployment Location')
param location string

@description('Secondary Deployment Locations')
param secondaryLocations array = []

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('New or Existing Kubernentes Resources')
@allowed([
  'new'
  'existing'
])
param newOrExistingKubernetes string = 'new'

@description('Name of Kubernetes Resource')
param aksName string = 'ddc-storage-${take(uniqueString(resourceGroup().id), 6)}'

@description('Number of Kubernetes Nodes')
param agentPoolCount int = 3

@description('Name of Kubernetes Agent Pool')
param agentPoolName string = 'k8agent'

@description('Virtual Machine Skew for Kubernetes')
param vmSize string = 'Standard_L16s_v2'

@description('Hostname of Deployment')
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

@description('Create new or use existing Storage Account.')
@allowed([
  'new'
  'existing'
])
param newOrExistingStorageAccount string = 'new'

@description('Name of Storage Account resource')
param storageAccountName string = 'ddc${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@description('Name of Storage Account Resource Group')
param storageResourceGroupName string = resourceGroup().name

@description('Create new or use existing Key Vault')
@allowed([
  'new'
  'existing'
])
param newOrExistingKeyVault string = 'new'

@description('Name of Key Vault resource')
param keyVaultName string = take('ddcKeyVault${uniqueString(resourceGroup().id, subscription().subscriptionId, location)}', 24)

@description('Create new or use existing Public IP resource')
@allowed([
  'new'
  'existing'
])
param newOrExistingPublicIp string = 'new'

@description('Name of Public IP Resource')
param publicIpName string = 'ddcPublicIP${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@description('Create new or use existing Traffic Manager Profile.')
@allowed([
  'new'
  'existing'
])
param newOrExistingTrafficManager string = 'new'

@description('New of Traffic Manager Profile.')
param trafficManagerName string = 'ddcPublicIP${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@description('Relative DNS name for the traffic manager profile, must be globally unique.')
param trafficManagerDnsName string = 'tmp-${uniqueString(resourceGroup().id, subscription().id)}'

@description('Create new or use existing CosmosDB for Cassandra.')
@allowed([
  'new'
  'existing'
])
param newOrExistingCosmosDB string = 'new'

@description('Name of Cosmos DB resource.')
param cosmosDBName string = 'ddc-db-${uniqueString(resourceGroup().id, subscription().subscriptionId)}'

@description('Name of Cosmos DB Resource Group.')
param cosmosDBRG string = resourceGroup().name

@description('Application Managed Identity ID')
param servicePrincipalClientID string = ''

@description('Worker Managed Identity ID, required for geo-replication.')
param workerServicePrincipalClientID string = ''

@description('Worker Managed Identity Secret, which will be stored in Key Vault, and is required for geo-replication.')
@secure()
param workerServicePrincipalSecret string = ''

@description('Name of Certificate (Default certificate is self-signed)')
param certificateName string = 'unreal-cloud-ddc-cert'

@description('Set to true to agree to the terms and conditions of the Epic Games EULA found here: https://store.epicgames.com/en-US/eula')
param epicEULA bool = false

@description('Active Directory Tennat ID')
param azureTenantID string = subscription().tenantId

@description('Tenant ID for Key Vault')
param keyVaultTenantID string = azureTenantID

@description('Tenant ID for Authentication')
param loginTenantID string = azureTenantID

@description('Namespace for Unreal DDC Contents')
param namespace string = 'defaultnamespace'

@description('Delete old ref records no longer in use across the entire system')
param CleanOldRefRecords bool = true

@description('Delete old blobs that are no longer referenced by any ref - this runs in each region to cleanup that regions blob stores')
param CleanOldBlobs bool = true

@secure()
param cassandraConnectionString string = ''

param storageConnectionStrings array = []

param helmVersion string = '0.2.5'

param managedIdentityPrefix string = 'id-ddc-storage-'

@description('Does the Managed Identity already exists, or should be created')
param useExistingManagedIdentity bool = false

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

@description('Set to false to deploy from as an ARM template for debugging') 
param isApp bool = true

var _artifactsLocationWithToken = _artifactsLocationSasToken != ''
var nodeLabels = 'horde-storage'

//  Resources
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
      nodeLabels: nodeLabels
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
    subject: 'system:serviceaccount:horde-tests:workload-identity-sa'
    storageAccountSecret: newOrExistingStorageAccount == 'existing' ? storageConnectionStrings[0] : ''
  }
}

module secondaryResources 'modules/resources.bicep' = [for (location, index) in secondaryLocations: if (epicEULA) {
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
      nodeLabels: nodeLabels
    }
    keyVaultName: take('${location}-${keyVaultName}', 24)
    publicIpName: '${publicIpName}-${location}'
    storageAccountName: '${take(location, 8)}${storageAccountName}'
    storageResourceGroupName: storageResourceGroupName
    storageSecretName: 'ddc-storage-connection-string'
    assignRole: assignRole
    isZoneRedundant: isZoneRedundant
    subject: 'system:serviceaccount:horde-tests:workload-identity-sa'
    storageAccountSecret: newOrExistingStorageAccount == 'existing' ? storageConnectionStrings[index+1] : ''
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
    useExistingManagedIdentity: useExistingManagedIdentity
    managedIdentityName: '${managedIdentityPrefix}${location}'
    rbacRolesNeededOnKV: '00482a5a-887f-4fb3-b363-3b7fe8e74483' // Key Vault Admin
    isApp: isApp
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

module cosmosDB 'modules/documentDB/databaseAccounts.bicep' = if(newOrExistingCosmosDB == 'new') {
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
    secretValue: newOrExistingCosmosDB == 'new' ? cosmosDB.outputs.cassandraConnectionString : cassandraConnectionString
  }
}]

module setuplocations 'modules/ddc-setup-locations.bicep' = if (assignRole && epicEULA) {
  name: 'setup-ddc-${location}'
  dependsOn: [
    cassandraKeys
    kvCert
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
    helmVersion: helmVersion
    useExistingManagedIdentity: true  // Reuse ID Created for Key Vault
    managedIdentityPrefix: managedIdentityPrefix
    existingManagedIdentitySubId: existingManagedIdentitySubId
    existingManagedIdentityResourceGroupName: existingManagedIdentityResourceGroupName
    isApp: isApp
  }
}
// End

@description('Location of required artifacts.')
output _artifactsLocation string = _artifactsLocation

@description('Token for retrieving  required Artifacts from storage.')
output _artifactsLocationWithToken bool = _artifactsLocationWithToken

@description('Name of Cosmos DB resource')
output cosmosDBName string = cosmosDBName

@description('New or Existing Cosmos DB resource')
output newOrExistingCosmosDB string = newOrExistingCosmosDB
