/*
Azure Bicep

This module simplifies placing the conneciton strings for the following resources into a Key Vault.
  Microsoft.DocumentDB/databaseAccounts
  Microsoft.EventHub/namespaces/eventhubs/authorizationRules
  Microsoft.Storage/storageAccounts
  Microsoft.CognitiveServices/accounts
  Microsoft.Batch/batchAccounts
  Microsoft.Cache/redis
  Microsoft.Maps/accounts
  Microsoft.OperationalInsights/workspaces
*/

@description('Deployment Location')
param location string

@description('Name of the Key Vault')
param keyVaultName string

@description('Primary connection string')
param primaryConnectionString bool = true

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingCassandraDB string = cassandraDBName == '' ? 'none' : cassandraConnectionString == '' ? 'new' : 'existing'
@description('Name of the Cassandra DB')
param cassandraDBName string = ''
@description('Name of the secret for the Cassandra DB')
param cassandraDBSecretName string = ''
@description('Custom Location String for Cassandra DB')
param locationString string = ''

@secure()
@description('Connection string for the Cassandra DB')
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
@description('Name of the Cosmos DB')
param cosmosDBName string = ''
@description('Name of the secret for the Cosmos DB')
param cosmosDBSecretName string = ''

@secure()
@description('Connection string for the Cosmos DB')
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
@description('Name of the Event Hub Namespace')
param eventHubNamespaceName string = ''
@description('Name of the Event Hub')
param eventHubName string = ''
@description('Name of the secret for the Event Hub')
param eventHubAuthorizationRulesName string = ''
@description('Name of the secret for the Event Hub')
param eventHubSecretName string = ''

@secure()
@description('Connection string for the Event Hub')
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
@description('Name of the Storage Account')
param storageAccountName string = ''
@description('Name of the secret for the Storage Account')
param storageSecretName string = ''

@secure()
@description('Connection string for the Storage Account')
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
@description('Name of the Cognitive Services Account')
param cognitiveServicesName string = ''
@description('Name of the secret for the Cognitive Services Account')
param cognitiveServicesSecretName string = ''

@secure()
@description('Connection string for the Cognitive Services Account')
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
@description('Name of the Batch Account')
param batchAccountName string = ''
@description('Name of the secret for the Batch Account')
param batchAccountSecretName string = ''

@secure()
@description('Connection string for the Batch Account')
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
@description('Name of the Redis Account')
param redisName string = ''
@description('Name of the secret for the Redis Account')
param redisSecretName string = ''

@secure()
@description('Connection string for the Redis Account')
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
@description('Name of the Maps Account')
param mapsAccountName string = ''
@description('Name of the secret for the Maps Account')
param mapsAccountSecretName string = ''

@secure()
@description('Connection string for the Maps Account')
param mapsAccountConnectionString string = ''

resource mapsAccount 'Microsoft.Maps/accounts@2021-02-01' existing = if (newOrExistingMapsAccount == 'new') {
  name: mapsAccountName
}

var mapSecret = newOrExistingMapsAccount == 'none' ? {} : {
  secretName: mapsAccountSecretName
  secretValue: newOrExistingMapsAccount == 'new' ? 'Key=${mapsAccount.listKeys().primaryKey}' : mapsAccountConnectionString
}

@allowed([ 'new', 'existing', 'none' ])
param newOrExistingOpertionalInsightsWorkspace string = opertionalInsightsWorkspaceName == '' ? 'none' : opertionalInsightsWorkspaceConnectionString == '' ? 'new' : 'existing'
@description('Name of the Operational Insights Workspace')
param opertionalInsightsWorkspaceName string = ''
@description('Name of the secret for the Operational Insights Workspace')
param opertionalInsightsWorkspaceSecretName string = ''

@secure()
@description('Connection string for the Operational Insights Workspace')
param opertionalInsightsWorkspaceConnectionString string = ''

resource opertionalInsightsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (newOrExistingOpertionalInsightsWorkspace == 'new') {
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

module secretsBatch 'modules/secretsBatch.bicep' = {
  name: 'secrets-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    keyVaultName: keyVaultName
    secrets: secrets
  }
}
