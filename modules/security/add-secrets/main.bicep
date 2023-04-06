@description('Deployment Location')
param location string
param keyVaultName string

@allowed([ 'new', 'existing', 'none'])
param newOrExistingCosmosDB string = 'none'
param cosmosDBName string = ''
param cosmosDBSecretName string = ''
param locationString string = ''

@secure()
param cassandraConnectionString string = ''

@allowed([ 'new', 'existing', 'none'])
param newOrExistingStorageAccount string = 'none'
param storageAccountName string = ''
param storageSecretName string = ''

@secure()
param storageAccountSecret string = ''

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = if(newOrExistingCosmosDB == 'new') {
  name: cosmosDBName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if(newOrExistingStorageAccount == 'new') {
  name: storageAccountName
}

var secrets = [
  newOrExistingCosmosDB == 'none' ? {} : {
    secretName: cosmosDBSecretName
    secretValue: newOrExistingCosmosDB == 'new' ? 'Contact Points=${cosmosDB.name}.cassandra.cosmos.azure.com,${locationString};Username=${cosmosDB.name};Password=${cosmosDB.listKeys().primaryMasterKey};Port=10350' : cassandraConnectionString
  }
  newOrExistingStorageAccount == 'none' ? {} : {
    secretName: storageSecretName
    secretValue: newOrExistingStorageAccount == 'new' ? 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}' : storageAccountSecret
  }
]

module secretsBatch 'vaults/secretsBatch.bicep' = {
  name: 'secrets-${uniqueString(location, resourceGroup().id, deployment().name)}'
  params: {
    keyVaultName: keyVaultName
    secrets: secrets
  }
}
