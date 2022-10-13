@description('Deployment Location')
@allowed([ 'australiaeast', 'australiasoutheast', 'eastus', 'westus2', 'westeurope', 'northeurope', 'canadacentral', 'canadaeast' ])
param location string

param subscriptionId string = subscription().id
param resourceGroupName string = resourceGroup().name
param applicationName string = 'app-${uniqueString(location, resourceGroup().id)}'

param plan object = {
  name: 'aks'
  product: 'horde-storage-preview'
  publisher: 'microsoft-azure-gaming'
  version: '0.0.15'
}

// https://learn.microsoft.com/en-us/rest/api/managedapplications/applications/create-or-update?tabs=HTTP
resource gdvm 'Microsoft.CustomProviders/resourceProviders@2018-09-01-preview' = {
  name: 'Microsoft.Gaming'
  location: location
  properties: {
    resourceTypes: [
      {
        name: 'GameDevelopmentVirtualMachine'
        routingType: 'Proxy'
        endpoint: 'https://management.azure.com${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Solutions/applications/${applicationName}'
        apiVersion: 'api-version=2019-07-01'
        properties: {
          location: 'East US 2'
          kind: 'MarketPlace'
          plan: plan
        }
      }
    ]
  }
}
