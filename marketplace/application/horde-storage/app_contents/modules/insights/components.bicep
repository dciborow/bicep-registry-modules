@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'
param config object = {
  'location': resourceGroup().location
  'tags': {
    'aia-industry': 'industry'
    'aia-solution': 'solution'
    'aia-version': '0.0'
  }
  'uniqueKey': uniqueString(resourceGroup().id)
}

var location  = config.location
var tags      = config.tags
var uniqueKey = config.uniqueKey

var uniqueAppInsightsName = 'appInsights-${uniqueKey}'

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = if (newOrExisting == 'new') {
  tags: tags
  name: uniqueAppInsightsName
  location: (((location == 'eastus2') || (location == 'westcentralus')) ? 'southcentralus' : location)
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output appInsights object = appInsights
output id           string = appInsights.id
