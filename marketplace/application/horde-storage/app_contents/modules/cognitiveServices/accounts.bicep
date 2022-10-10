param config object = {
  'location': resourceGroup().location
  'tags': {
    'aia-industry': 'industry'
    'aia-solution': 'solution'
    'aia-version': '0.0'
  }
  'uniqueKey': uniqueString(resourceGroup().id)
  'enable': {
    'vNET': false
    'cogService': true
  }
  'resources': {
    'cogServiceName': 'cogService${uniqueString(resourceGroup().id)}'
  }
}
param sku string = 'S0'
param kind string = 'FormRecognizer'
param cogServiceSubnet string = ''


var networkAcls = config.enable.vNET ? {
  defaultAction: 'Deny'
  virtualNetworkRules: [
    {
      action: 'Allow'
      id: cogServiceSubnet
    }
  ]
} : {}
resource cogSvc 'Microsoft.CognitiveServices/accounts@2021-04-30' = if (config.enable.cogService) {
  name: config.resources.cogService
  location: config.location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    customSubDomainName: 'subDomain${config.resources.cogService}'
    networkAcls: networkAcls
    privateEndpointConnections: []
    publicNetworkAccess: 'Enabled'
  }
}

output id string = cogSvc.id
