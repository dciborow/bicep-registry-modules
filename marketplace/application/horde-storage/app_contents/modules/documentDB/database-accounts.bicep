param accountName string = uniqueString(resourceGroup().id)
param config object = {
  'location': resourceGroup().location
  'tags': {
    'aia-industry': 'industry'
    'aia-solution': 'solution'
    'aia-version': '0.0'
  }
  'uniqueKey': uniqueString(resourceGroup().id)
  'enable': {
    'vnet': false
  }
}

param databaseAccountOfferType string = 'Standard'
resource accountName_resource 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
  name: accountName
  tags: config.tags
  location: config.location
  properties: {
    locations: [
      {
        locationName: config.location
      }
    ]
    databaseAccountOfferType: databaseAccountOfferType
  }
}
