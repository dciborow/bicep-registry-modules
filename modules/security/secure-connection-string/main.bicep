@description('Deployment Location')
param location string
param keyVaultName string

@allowed([ 'new', 'existing', 'none'])
param newOrExistingCassandraDB string = 'none'
param cassandraDBName string = ''
param cassandraDBSecretName string = ''
param locationString string = ''

@secure()
param cassandraConnectionString string = ''

@allowed([ 'new', 'existing', 'none'])
param newOrExistingCosmosDB string = 'none'
param cosmosDBName string
param cosmosDBSecretName string

@secure()
param cosmosConnectionString string = ''

@allowed([ 'new', 'existing', 'none'])
param newOrExistingEventHub string = 'none'
param eventHubNamespaceName string = ''
param eventHubName string = ''
param eventHubAuthorizationRules string = ''
param eventHubSecretName string = ''

@secure()
param eventhubConnectionString string = ''

@allowed([ 'new', 'existing', 'none'])
param newOrExistingStorageAccount string = 'none'
param storageAccountName string = ''
param storageSecretName string = ''

@secure()
param storageAccountConnectionString string = ''

param primaryConnectionString bool = true
param secondaryConnectionString bool = false
param primaryKey bool = false
param secondaryKey bool = false

resource cassandraDB 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = if(newOrExistingCassandraDB == 'new') {
  name: cassandraDBName
}

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = if(newOrExistingCosmosDB == 'new') {
  name: cosmosDBName
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-01-01-preview' existing = if(newOrExistingEventHub == 'new') {
  name: eventHubNamespaceName
}

resource eventHubs 'Microsoft.EventHub/namespaces/eventhubs@2021-01-01-preview' existing = if(newOrExistingEventHub == 'new') {
  parent: eventHubNamespace
  name: eventHubName
}

resource eventHubAuthorizationRules 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-01-01-preview' existing = if(newOrExistingEventHub == 'new') {
  parent: eventHubs
  name: eventHubAuthorizationRules
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if(newOrExistingStorageAccount == 'new') {
  name: storageAccountName
}

var secrets = [
  newOrExistingCassandraDB == 'none' ? {} : {
    secretName: cassandraDBSecretName
    secretValue: newOrExistingCassandraDB == 'new' ? 'Contact Points=${cassandraDB.name}.cassandra.cosmos.azure.com,${locationString};Username=${cassandraDB.name};Password=${cassandraDB.listKeys().primaryMasterKey};Port=10350' : cassandraConnectionString
  }
  newOrExistingCosmosDB == 'none' ? {} : {
    secretName: cosmosDBSecretName
    secretValue: newOrExistingCosmosDB == 'new' ? 'AccountEndpoint=https://${cosmosDB.name}.documents.azure.com:443/;AccountKey=${cosmosDB.listKeys().primaryMasterKey}' : cosmosConnectionString
  }
  newOrExistingEventHub == 'none' ? {} : {
    secretName: eventhubSecretName
    secretValue: newOrExistingEventHub == 'new' ? eventHubAuthorizationRules.listKeys().primaryConnectionString : eventhubConnectionString
  }
  newOrExistingStorageAccount == 'none' ? {} : {
    secretName: storageSecretName
    secretValue: newOrExistingStorageAccount == 'new' ? 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}' : storageAccountConnectionString
  }
]

module secretsBatch 'vaults/secretsBatch.bicep' = {
  name: 'secrets-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    keyVaultName: keyVaultName
    secrets: secrets
  }
}
