@description('Name of private DNS zone')
param zoneName string

@description('Array of virtual networks to link to this private DNS zone. Each is an object with a vnetId property and a location property')
param vnetLinkSpecs array

// For a [private] DNS zone, the location is expected to be 'global', not a specific region.
var zoneLocation = 'global'

resource zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: zoneLocation
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for spec in vnetLinkSpecs: {
  name: 'link-${spec.location}'
  location: zoneLocation // Global, not the location of the vnet
  tags: {
    tagName1: 'tagValue1'
    tagName2: 'tagValue2'
  }
  parent: zone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: spec.vnetId
    }
  }
}]
