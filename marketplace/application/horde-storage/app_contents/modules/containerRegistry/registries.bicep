param config object = {
  'location': resourceGroup().location
  'tags': {
    'aia-industry': 'industry'
    'aia-solution': 'solution'
    'aia-version': '0.0'
  }
  'enable': {
    'vNET': false
  }
  'resources': {
    'registries': 'acr${uniqueString(resourceGroup().id)}'
  }
  'registries': {
    'properties': {
      adminUserEnabled: false
    }
    sku: {
      name: 'Standard'
    }    
  }
}

resource acrName 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: config.resources.registries
  location: config.location
  tags: config.tags
  sku: config.registries.sku
  properties: config.registries.properties
}
