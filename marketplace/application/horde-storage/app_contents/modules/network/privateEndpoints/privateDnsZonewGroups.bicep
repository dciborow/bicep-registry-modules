param privateEndpointName string
param config object = {
  'location': resourceGroup().location
}

resource privateEndpointName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: '${privateEndpointName}/default'
  location: config.location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: '/subscriptions/95f31ea2-0e41-4d66-a5db-9ef0449ad928/resourceGroups/dcibrg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
        }
      }
    ]
  }
}
