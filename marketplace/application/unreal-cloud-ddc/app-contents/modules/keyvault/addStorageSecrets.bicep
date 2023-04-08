@description('Deployment Location')
param location string
param keyVaultName string
param storageAccountName string
param storageResourceGroupName string
param storageSecretName string

@allowed([ 'new', 'existing', 'none'])
param newOrExistingStorageAccount string = 'new'

@secure()
param storageAccountSecret string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if(newOrExistingStorageAccount == 'new') {
  scope: resourceGroup(storageResourceGroupName)
  name: take(storageAccountName, 24)
}

module secretsBatch 'vaults/secretsBatch.bicep' = if(newOrExistingStorageAccount != 'none') {
  name: 'secrets-${uniqueString(location, resourceGroup().id, deployment().name)}'
  dependsOn: [
    storageAccount
  ]
  params: {
    keyVaultName: keyVaultName
    secrets: [ {
      secretName: storageSecretName
      secretValue: newOrExistingStorageAccount == 'new' ? 'DefaultEndpointsProtocol=https;AccountName=${take(storageAccountName, 24)};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}' : storageAccountSecret
    } ]
  }
}
