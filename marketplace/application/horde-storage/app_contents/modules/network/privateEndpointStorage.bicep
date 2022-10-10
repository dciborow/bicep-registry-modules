param location string
param privateEndpointName string
param privateLinkResource string
param targetSubResource array
param subnet string
param virtualNetworkId string
param privateDnsDeploymentName string

resource privateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-03-01' = {
  location: location
  name: privateEndpointName
  properties: {
    subnet: {
      id: subnet
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkResource
          groupIds: targetSubResource
        }
      }
    ]
  }
  tags: {}
}

module privateDnsDeploymentName_resource './privateDnsZones.bicep' = {
  name: privateDnsDeploymentName
  params: {}
  dependsOn: [
    privateEndpointName_resource
  ]
}

module VirtualNetworkLink './virtualNetworkLinks.bicep' = {
  name: 'VirtualNetworkLink-20210730005522'
  params: {
    virtualNetworkId: virtualNetworkId
  }
  dependsOn: [
    privateDnsDeploymentName_resource
  ]
}

module DnsZoneGroup './privateEndpoints/privateDnsZonewGroups.bicep' = {
  name: 'DnsZoneGroup-20210730005522'
  scope: resourceGroup('dcibrg')
  params: {
    privateEndpointName: privateEndpointName
    location: location
  }
  dependsOn: [
    privateEndpointName_resource
    privateDnsDeploymentName_resource
  ]
}
