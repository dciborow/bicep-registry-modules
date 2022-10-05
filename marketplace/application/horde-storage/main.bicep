param name                     string = 'horde-cluster'
param agentPoolName            string = 'k8agent'
param location                 string = 'eastus2'
param managedResourceGroupName string = 'mrg'
param agentPoolCount           int    = 3

var managedResourceGroupId = '${subscription().id}/resourceGroups/${resourceGroup().name}-${managedResourceGroupName}'

resource hordeStorage 'Microsoft.Solutions/applications@2017-09-01' = {
  location: location
  kind: 'MarketPlace'
  name: name
  plan: {
    name: 'aks'
    product: 'horde-storage-preview'
    publisher: 'microsoft-azure-gaming'
    version: '0.0.15'
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      location: {
        value: location
      }
      name: {
        value: name
      }
      agentPoolCount: {
        value: agentPoolCount
      }
      agentPoolName: {
        value: agentPoolName
      }
    }
    jitAccessPolicy: null
  }
}
