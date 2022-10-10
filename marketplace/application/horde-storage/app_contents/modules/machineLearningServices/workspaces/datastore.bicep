param azureMLName string
param blobDatastoreName string
param location string = resourceGroup().location
param storageAccountName_var string
param blobDataContainerName string
param storageAccountID string

@description('Optional : If set to true, the call will skip datastore validation. Defaults to false')
param skipValidation bool = true

@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

resource workspaceName_blobDatastoreName 'Microsoft.MachineLearningServices/workspaces/datastores@2020-06-01' = if (newOrExisting == 'new') {
  name: '${azureMLName}/${blobDatastoreName}'
  location: location
  properties: {
    DataStoreType: 'blob'
    SkipValidation: skipValidation
    AccountName: storageAccountName_var
    ContainerName: blobDataContainerName
    AccountKey: listkeys(storageAccountID, '2021-04-01').keys[0].value
    StorageAccountSubscriptionId: subscription().subscriptionId
    StorageAccountResourceGroup: resourceGroup().name
  }
}
output id string = workspaceName_blobDatastoreName.id
