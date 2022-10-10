param config object = {
  'location': resourceGroup().location
  'resources': {
    'searchName': 'search${uniqueString(resourceGroup().name)}'
  }
  'search': {
    'sku': {
      'name': 'storage_optimized_l1'
    }
    'properties': {
      'searchSku': 'storage_optimized_l1'
      'partitionCount': 1
      'replicaCount': 1
    }
  }
}

resource searchSvc 'Microsoft.Search/searchServices@2020-08-01' = {
  name: config.resources.searchName
  location: config.location
  sku: config.search.sku
  properties: config.search.properties
}
