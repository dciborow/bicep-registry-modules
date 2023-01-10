//  Parameters
@description('Deployment Location')
param location string = resourceGroup().location

param resourceGroupName string = resourceGroup().name

@description('Secondary Deployment Locations')
param secondaryLocations array = []

@allowed([ 'new', 'existing' ])
param newOrExistingKubernetes string = 'new'
param prefix string = uniqueString(location, resourceGroup().id, deployment().name)
param name string = 'horde-storage'
param agentPoolCount int = 2
param agentPoolName string = 'k8agent'
param vmSize string = 'Standard_L8s_v3'
param hostname string = 'deploy1.horde-storage.gaming.azure.com'
param isZoneRedundant bool = false

@description('Running this template requires roleAssignment permission on the Resource Group, which require an Owner role. Set this to false to deploy some of the resources')
param assignRole bool = true

@allowed([ 'Standard', 'Premium' ])
@description('Storage Account Tier. Standard or Premium.')
param storageAccountTier string = 'Standard'

@description('Storage Account Type. Use Zonal Redundant Storage when able.')
param storageAccountType string = isZoneRedundant ? '${storageAccountTier}_ZRS' : '${storageAccountTier}_LRS'

param storageAccountName string = string('hordestore${uniqueString(resourceGroup().id, subscription().subscriptionId, location, storageAccountType)}')

@allowed([ 'new', 'existing' ])
param newOrExistingKeyVault string = 'new'
param keyVaultName string = take('${uniqueString(resourceGroup().id, subscription().subscriptionId, publishers[publisher].version, location)}', 24)

@allowed([ 'new', 'existing' ])
param newOrExistingPublicIp string = 'new'
param publicIpName string = string('hordePublicIP${uniqueString(resourceGroup().id, subscription().subscriptionId, publishers[publisher].version, location)}')

@allowed([ 'new', 'existing' ])
param newOrExistingTrafficManager string = 'new'
param trafficManagerName string = string('hordePublicIP${uniqueString(resourceGroup().id, subscription().subscriptionId, publishers[publisher].version, location)}')
@description('Relative DNS name for the traffic manager profile, must be globally unique.')
param trafficManagerDnsName string = string('tmp-${uniqueString(resourceGroup().id, subscription().id)}')

@allowed([ 'new', 'existing' ])
param newOrExistingCosmosDB string = 'new'
param cosmosDBName string = string('hordeDB-${uniqueString(resourceGroup().id, subscription().subscriptionId, location)}')
param servicePrincipalClientID string = ''
param workerServicePrincipalClientID string = servicePrincipalClientID
param managedResourceGroupName string = 'mrg'
param marketplace bool = true

@secure()
param workerServicePrincipalSecret string = ''

@description('Enable to configure certificate. Default: true')
param enableCert bool = true

@description('Name of Certificate (Default certificate is self-signed)')
param certificateName string = 'unreal-cloud-ddc-cert'

@description('Set to true to agree to the terms and conditions of the Epic Games EULA found here: https://store.epicgames.com/en-US/eula')
param epicEULA bool = false

@allowed([ 'dev', 'prod' ])
param publisher string = 'prod'
param publishers object = {
  dev: {
    name: 'preview'
    product: 'unreal-cloud-ddc-temp'
    publisher: 'microsoftcorporation1590077852919'
    version: '0.0.0'
  }
  prod: {
    name: 'preview'
    product: 'unreal-cloud-ddc-preview'
    publisher: 'microsoft-azure-gaming'
    version: '0.1.28'
  }
}

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''
// End

//  Variables
var certificateIssuer = 'Subscription-Issuer'
var issuerProvider = 'OneCertV2-PublicCA'
var managedResourceGroupId = '${subscription().id}/resourceGroups/${resourceGroup().name}-${managedResourceGroupName}-${replace(publishers[publisher].version,'.','-')}'
var appName = '${prefix}${name}-${replace(publishers[publisher].version,'.','-')}'
// End

module cassandra 'app-contents/modules/documentDB/databaseAccounts.bicep' = {
  name: 'cassandra-${uniqueString(location, resourceGroup().name)}'
  params: {
    location: location
    secondaryLocations: secondaryLocations
    newOrExisting: newOrExistingCosmosDB
    name: 'ddc${cosmosDBName}'
  }
}

var secondaryRegions = [for (region, i) in secondaryLocations: {
  locationName: contains(region, 'locationName') ? region.locationName : region
  failoverPriority: contains(region, 'failoverPriority') ? region.failoverPriority : i + 1
  isZoneRedundant: contains(region, 'isZoneRedundant') ? region.isZoneRedundant : isZoneRedundant
}]

var locations = union([
    {
      locationName: location
      failoverPriority: 0
      isZoneRedundant: isZoneRedundant
    }
  ], secondaryRegions)

resource cassandraDB 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = {
  name: cassandra.name
}

var unwind = [for location in locations: '${toLower(name)}-${location.locationName}.cassandra.cosmos.azure.com']
var locationString = replace(substring(string(unwind), 1, length(string(unwind))-2), '"', '')
var cassandraConnectionString = 'Contact Points=${toLower(name)}.cassandra.cosmos.azure.com,${locationString};Username=${toLower(name)};Password=${cassandraDB.listKeys().primaryMasterKey};Port=10350'

module storageAccount 'app-contents/modules/storage/storageAccounts.bicep' = [for location in union([ location ], secondaryLocations): {
  name: 'storageAccount-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    location: location
    name: take('${take(location, 8)}${storageAccountName}',24)
    storageAccountTier: storageAccountTier
    storageAccountType: storageAccountType
  }
}]

resource existingStorageAccounts 'Microsoft.Storage/storageAccounts@2019-06-01' = [for location in union([ location ], secondaryLocations): {
  name: take('${take(location, 8)}${storageAccountName}',24)
}]

var keys = newOrExisting == 'new' ? listKeys(newStorageAccount.id, newStorageAccount.apiVersion) : listKeys(storageAccount.id, storageAccount.apiVersion)
var blobStorageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${keys.keys[0].value}'



module trafficManager 'app-contents/modules/network/trafficManagerProfiles.bicep' = {
  name: 'trafficManager-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    name: '${prefix}ddc'
    newOrExisting: 'new'
    trafficManagerDnsName: '${prefix}preview.unreal-cloud-ddc'
  }
}

resource hordeStorage 'Microsoft.Solutions/applications@2021-07-01' = if(marketplace) {
  location: location
  kind: 'MarketPlace'
  name: appName
  plan: publishers[publisher]
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      location: {
        value: location
      }
      secondaryLocations: {
        value: secondaryLocations
      }
      newOrExistingKubernetes: {
        value: newOrExistingKubernetes
      }
      aksName: {
        value: name
      }
      agentPoolCount: {
        value: agentPoolCount
      }
      agentPoolName: {
        value: agentPoolName
      }
      vmSize: {
        value: vmSize
      }
      hostname: {
        value: hostname
      }
      certificateIssuer: {
        value: certificateIssuer
      }
      issuerProvider: {
        value: issuerProvider
      }
      assignRole: {
        value: assignRole
      }
      newOrExistingStorageAccount: {
        value: 'existing'
      }
      storageAccountName: {
        value: storageAccountName
      }
      storageResourceGroupName: {
        value: resourceGroupName
      }      
      newOrExistingKeyVault: {
        value: newOrExistingKeyVault
      }
      keyVaultName: {
        value: keyVaultName
      }
      newOrExistingPublicIp: {
        value: newOrExistingPublicIp
      }
      publicIpName: {
        value: publicIpName
      }
      newOrExistingTrafficManager: {
        value: newOrExistingTrafficManager
      }
      trafficManagerName: {
        value: trafficManagerName
      }
      trafficManagerDnsName: {
        value: '${trafficManagerDnsName}-${replace(publishers[publisher].version,'.','-')}'
      }
      newOrExistingCosmosDB: {
        value: 'existing'
      }
      cosmosDBName: {
        value: 'ddc${cosmosDBName}'
      }
      cosmosDBRG: {
        value: resourceGroupName
      }
      servicePrincipalClientID: {
        value: servicePrincipalClientID
      }
      workerServicePrincipalClientID: {
        value: workerServicePrincipalClientID
      }
      workerServicePrincipalSecret: {
        value: workerServicePrincipalSecret
      }
      certificateName: {
        value: certificateName
      }
      epicEULA: {
        value: epicEULA
      }
      isZoneRedundant: {
        value: isZoneRedundant
      }
      enableCert: {
        value: enableCert
      }
      cassandraConnectionString: {
        value: cassandraConnectionString
      }
    }
    jitAccessPolicy: null
  }
}

module ucDDC 'app-contents/mainTemplate.bicep' = if (!marketplace) {
  name: appName
  params: {
    location: location
    secondaryLocations: secondaryLocations
    newOrExistingKubernetes: newOrExistingKubernetes
    aksName: name
    agentPoolCount: agentPoolCount
    agentPoolName: agentPoolName
    vmSize: vmSize
    hostname: hostname
    certificateIssuer: certificateIssuer
    issuerProvider: issuerProvider
    assignRole: assignRole
    newOrExistingStorageAccount: 'existing'
    storageAccountName: storageAccountName
    storageResourceGroupName: resourceGroupName
    newOrExistingKeyVault: newOrExistingKeyVault
    keyVaultName: keyVaultName
    newOrExistingPublicIp: newOrExistingPublicIp
    publicIpName: publicIpName
    newOrExistingTrafficManager: newOrExistingTrafficManager
    trafficManagerName: trafficManagerName
    trafficManagerDnsName: '${trafficManagerDnsName}-${replace(publishers[publisher].version,'.','-')}'
    newOrExistingCosmosDB: 'existing'
    cosmosDBRG: resourceGroupName
    servicePrincipalClientID: servicePrincipalClientID
    workerServicePrincipalClientID: workerServicePrincipalClientID
    workerServicePrincipalSecret: workerServicePrincipalSecret
    certificateName: certificateName
    epicEULA: epicEULA
    isZoneRedundant: isZoneRedundant
    enableCert: enableCert
    cassandraConnectionString: cassandraConnectionString
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken:_artifactsLocationSasToken
  }
}

output prefix string = prefix
output appName string = appName
