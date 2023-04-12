@description('Deployment Location')
param location string

@description('Toggle to enable or disable zone redudance.')
param isZoneRedundant bool = false

@description('Toggle to enable or disable virtual networks.')
param enableVirtualNetwork bool = false

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingStorageAccount string = 'none'
param storageAccountPrefix string = 'store'
@maxLength(24)
param storageAccountName string = take('${storageAccountPrefix}${uniqueString(resourceGroup().id, subscription().id)}', 24)
param storageResourceGroupName string = resourceGroup().name
param storageProperties object = {}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingCosmosDB string = 'none'
param cosmosDBPrefix string = 'cosmos'
@maxLength(64)
param cosmosDBName string = take('${cosmosDBPrefix}${uniqueString(resourceGroup().id, subscription().id)}', 64)
param cosmosDBResourceGroupName string = resourceGroup().name
param cosmosDBProperties object = {}

var newOrExisting = {
  new: 'new'
  existing: 'existing'
}

var enableStorage = newOrExistingStorageAccount != 'none'
var enableCosmos = newOrExistingCosmosDB != 'none'

var noAvailabilityZones = [
  'northcentralus'
  'westus'
  'jioindiawest'
  'westcentralus'
  'australiacentral'
  'australiacentral2'
  'australiasoutheast'
  'japanwest'
  'jioindiacentral'
  'koreasouth'
  'southindia'
  'francesouth'
  'germanynorth'
  'norwayeast'
  'switzerlandwest'
  'ukwest'
  'uaecentral'
  'brazilsoutheast'
]

module storageAccount 'br/public:storage/storage-acount:0.0.1' = if (enableStorage) {
  name: 'storageAccount-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    location: location
    prefix: storageAccountPrefix
    name: storageAccountName
    newOrExisting: newOrExisting[newOrExistingStorageAccount]
    resourceGroupName: storageResourceGroupName
    enableVirtualNetwork: enableVirtualNetwork
    isZoneRedundant: isZoneRedundant && !contains(noAvailabilityZones, location)
    properties: storageProperties
  }
}

module cosmosDb 'br/public:data/cosmos-db:1.0.1' = if (enableCosmos) {
  name: 'cosmosdb-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    location: location
    prefix: cosmosDBPrefix
    name: cosmosDBName
    newOrExisting: newOrExisting[newOrExistingCosmosDB]
    resourceGroupName: cosmosDBResourceGroupName
    enableVirtualNetwork: enableVirtualNetwork
    isZoneRedundant: isZoneRedundant && !contains(noAvailabilityZones, location)
    cosmosDBProperties: cosmosDBProperties
  }
}
