param acrName string
param location string = resourceGroup().location
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

resource acr 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = if (newOrExisting == 'new') {
  name: acrName
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}
output id string = acr.id
