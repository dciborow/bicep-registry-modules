// Azure Bicep
// Microsoft.DocumentDB/databaseAccounts
// Microsoft.EventHub/namespaces/eventhubs/authorizationRules
// Microsoft.Storage/storageAccounts
// Microsoft.CognitiveServices/accounts
// Microsoft.Batch/batchAccounts
// Microsoft.Cache/redis
// Microsoft.Maps/accounts
// Microsoft.OperationalInsights/workspaces
@description('Deployment Location')
param location string
param keyVaultName string

param primaryConnectionString bool = true

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingCassandraDB string = cassandraDBName == '' ? 'none' : cassandraConnectionString == '' ? 'new' : 'existing'
param cassandraDBName string = ''
param cassandraDBSecretName string = ''
param locationString string = ''

@secure()
param cassandraConnectionString string = ''

resource cassandraDB 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = if (newOrExistingCassandraDB == 'new') {
  name: cassandraDBName
}

var cassandraSecret = newOrExistingCassandraDB == 'none' ? {} : {
  secretName: cassandraDBSecretName
  secretValue: newOrExistingCassandraDB == 'new' ? 'Contact Points=${cassandraDB.name}.cassandra.cosmos.azure.com,${locationString};Username=${cassandraDB.name};Password=${cassandraDB.listKeys().primaryMasterKey};Port=10350' : cassandraConnectionString
}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingCosmosDB string = cosmosDBName == '' ? 'none' : cosmosConnectionString == '' ? 'new' : 'existing'
param cosmosDBName string = ''
param cosmosDBSecretName string = ''

@secure()
param cosmosConnectionString string = ''

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = if (newOrExistingCosmosDB == 'new') {
  name: cosmosDBName
}

var cosmosDBSecret = newOrExistingCosmosDB == 'none' ? {} : {
  secretName: cosmosDBSecretName
  secretValue: newOrExistingCosmosDB == 'new' ? 'AccountEndpoint=https://${cosmosDB.name}.documents.azure.com:443/;AccountKey=${cosmosDB.listKeys().primaryMasterKey}' : cosmosConnectionString
}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingEventHub string = eventHubNamespaceName == '' ? 'none' : eventhubConnectionString == '' ? 'new' : 'existing'
param eventHubNamespaceName string = ''
param eventHubName string = ''
param eventHubAuthorizationRulesName string = ''
param eventHubSecretName string = ''

@secure()
param eventhubConnectionString string = ''

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-01-01-preview' existing = if (newOrExistingEventHub == 'new') {
  name: eventHubNamespaceName
}

resource eventHubs 'Microsoft.EventHub/namespaces/eventhubs@2021-01-01-preview' existing = if (newOrExistingEventHub == 'new') {
  parent: eventHubNamespace
  name: eventHubName
}

resource eventHubAuthorizationRules 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-01-01-preview' existing = if (newOrExistingEventHub == 'new') {
  parent: eventHubs
  name: eventHubAuthorizationRulesName
}

var eventHubSecret = newOrExistingEventHub == 'none' ? {} : {
  secretName: eventHubSecretName
  secretValue: newOrExistingEventHub == 'new' ? primaryConnectionString ? eventHubAuthorizationRules.listKeys().primaryConnectionString : eventHubAuthorizationRules.listKeys().secondaryConnectionString : eventhubConnectionString
}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingStorageAccount string = storageAccountName == '' ? 'none' : storageAccountConnectionString == '' ? 'new' : 'existing'
param storageAccountName string = ''
param storageSecretName string = ''

@secure()
param storageAccountConnectionString string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if (newOrExistingStorageAccount == 'new') {
  name: storageAccountName
}

var storageSecret = newOrExistingStorageAccount == 'none' ? {} : {
  secretName: storageSecretName
  secretValue: newOrExistingStorageAccount == 'new' ? 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}' : storageAccountConnectionString
}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingCognitiveServices string = cognitiveServicesName == '' ? 'none' : cognitiveServicesConnectionString == '' ? 'new' : 'existing'
param cognitiveServicesName string = ''
param cognitiveServicesSecretName string = ''

@secure()
param cognitiveServicesConnectionString string = ''

resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2017-04-18' existing = if (newOrExistingCognitiveServices == 'new') {
  name: cognitiveServicesName
}

var cognitiveServicesSecret = newOrExistingCognitiveServices == 'none' ? {} : {
  secretName: cognitiveServicesSecretName
  secretValue: newOrExistingCognitiveServices == 'new' ? 'Endpoint=https://${cognitiveServices.name}.cognitiveservices.azure.com/;ApiKey=${cognitiveServices.listKeys().key1}' : cognitiveServicesConnectionString
}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingBatchAccount string = batchAccountName == '' ? 'none' : batchAccountConnectionString == '' ? 'new' : 'existing'
param batchAccountName string = ''
param batchAccountSecretName string = ''

@secure()
param batchAccountConnectionString string = ''

resource batchAccount 'Microsoft.Batch/batchAccounts@2019-08-01' existing = if (newOrExistingBatchAccount == 'new') {
  name: batchAccountName
}

var batchAccountSecret = newOrExistingBatchAccount == 'none' ? {} : {
  secretName: batchAccountSecretName
  secretValue: newOrExistingBatchAccount == 'new' ? 'AccountEndpoint=https://${batchAccount.name}.${locationString}.batch.azure.com;AccountKey=${batchAccount.listKeys().key1}' : batchAccountConnectionString
}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingRedis string = redisName == '' ? 'none' : redisConnectionString == '' ? 'new' : 'existing'
param redisName string = ''
param redisSecretName string = ''

@secure()
param redisConnectionString string = ''

resource redis 'Microsoft.Cache/redis@2018-03-01' existing = if (newOrExistingRedis == 'new') {
  name: redisName
}

var redisSecret = newOrExistingRedis == 'none' ? {} : {
  secretName: redisSecretName
  secretValue: newOrExistingRedis == 'new' ? 'RedisEndpoint=${redis.name}.redis.cache.windows.net;Password=${redis.listKeys().primaryMasterKey}' : redisConnectionString
}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingMapsAccount string = mapsAccountName == '' ? 'none' : mapsAccountConnectionString == '' ? 'new' : 'existing'
param mapsAccountName string = ''
param mapsAccountSecretName string = ''

@secure()
param mapsAccountConnectionString string = ''

resource mapsAccount 'Microsoft.Maps/accounts@2020-02-01' existing = if (newOrExistingMapsAccount == 'new') {
  name: mapsAccountName
}

var mapSecret = newOrExistingMapsAccount == 'none' ? {} : {
  secretName: mapsAccountSecretName
  secretValue: newOrExistingMapsAccount == 'new' ? 'Key=${mapsAccount.listKeys().primaryKey}' : mapsAccountConnectionString
}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingOpertionalInsightsWorkspace string = opertionalInsightsWorkspaceName == '' ? 'none' : opertionalInsightsWorkspaceConnectionString == '' ? 'new' : 'existing'
param opertionalInsightsWorkspaceName string = ''
param opertionalInsightsWorkspaceSecretName string = ''

@secure()
param opertionalInsightsWorkspaceConnectionString string = ''

resource opertionalInsightsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01' existing = if (newOrExistingOpertionalInsightsWorkspace == 'new') {
  name: opertionalInsightsWorkspaceName
}

var operationalInsightSecret = newOrExistingOpertionalInsightsWorkspace == 'none' ? {} : {
  secretName: opertionalInsightsWorkspaceSecretName
  secretValue: newOrExistingOpertionalInsightsWorkspace == 'new' ? 'Key=${opertionalInsightsWorkspace.listKeys().primaryKey}' : opertionalInsightsWorkspaceConnectionString
}

var secrets = [
  cassandraSecret
  cosmosDBSecret
  eventHubSecret
  storageSecret
  cognitiveServicesSecret
  batchAccountSecret
  redisSecret
  mapSecret
  operationalInsightSecret
]

module secretsBatch 'vaults/secretsBatch.bicep' = {
  name: 'secrets-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    keyVaultName: keyVaultName
    secrets: secrets
  }
}
