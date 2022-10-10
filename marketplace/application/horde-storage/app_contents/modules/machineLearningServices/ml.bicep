param azureMLName string
param location string = resourceGroup().location
param tags object
param appInsightsID string
param keyVaultID string
param dataAccountID string
param subnet_id string
param enableMLCompute bool = true

module azureML './machinelearningservices/workspace.bicep' = {
  name: 'ml_workspace'
  params: {
    azureMLName: azureMLName
    location: location
    tags: tags
    appInsights: appInsightsID
    keyVault: keyVaultID
    dataAccount: dataAccountID
  }
}
module azureMLCompute './machinelearningservices/ml_compute.bicep' =  if (enableMLCompute) {
  name: 'ml_compute'
  params: {
    azureMLName: azureMLName
    location: location
    subnetAML: subnet_id
  }
}
