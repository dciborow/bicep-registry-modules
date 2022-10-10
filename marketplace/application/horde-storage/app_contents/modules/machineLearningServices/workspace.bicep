param location    string
param azureMLName string
param appInsights string
param keyVault    string
param dataAccount string
param tags        object = {
  'aia-industry': 'industry'
  'aia-solution': 'solution'
  'aia-version' : '0.0'
}

@description('The flag to signal High Business Impact (HBI) data in the AML workspace and reduce diagnostic data collected by the service')
param hbiWorkspace bool = false

@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

var azureMLSku = 'basic'

resource azureML 'Microsoft.MachineLearningServices/workspaces@2020-06-01' = if (newOrExisting == 'new') {
  tags: tags
  name: azureMLName
  location: location
  sku: {
    name: azureMLSku
    tier: azureMLSku
  }
  properties: {
    applicationInsights: appInsights
    friendlyName: azureMLName
    keyVault: keyVault
    storageAccount: dataAccount
    hbiWorkspace: hbiWorkspace
  }
  identity: {
    type: 'SystemAssigned'
  }  
}
output id string = azureML.id
