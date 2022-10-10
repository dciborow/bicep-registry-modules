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
    'website': 'website${uniqueString(resourceGroup().id)}'
  }
}
param skuName string
param skuCapacity int

resource hostingPlanName 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'host${config.resources.website}'
  location: config.location
  tags: config.tags
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  properties: {
    reserved: true
  }
}
output id string = hostingPlanName.id
