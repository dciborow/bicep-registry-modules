@description('Deployment Location')
param location string
param keyVaultName string
param cosmosDBName string
param cosmosDBRG string
param cosmosDBSecretName string
param locationString string

@allowed([ 'new', 'existing'])
param newOrExistingCosmosDB string = 'new'

@secure()
param cassandraConnectionString string = ''

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = if(newOrExistingCosmosDB == 'new') {
  scope: resourceGroup(cosmosDBRG)
  name: cosmosDBName
}

module secretsBatch 'vaults/secretsBatch.bicep' = {
  name: 'secrets-cosmos-${uniqueString(location, resourceGroup().id, deployment().name)}'
  dependsOn: [
    cosmosDB
  ]
  params: {
    keyVaultName: keyVaultName
    secrets: [ {
      secretName: cosmosDBSecretName
      secretValue: newOrExistingCosmosDB == 'new' ? 'Contact Points=${cosmosDB.name}.cassandra.cosmos.azure.com,${locationString};Username=${cosmosDB.name};Password=${cosmosDB.listKeys().primaryMasterKey};Port=10350' : cassandraConnectionString
    } ]
  }
}
