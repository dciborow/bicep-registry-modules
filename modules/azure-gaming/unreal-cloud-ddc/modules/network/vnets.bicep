@description('Array of objects, each one having a name and location')
param vnetSpecs array

param overallAddrPrefix string
param regionAddrRange int
param subnetAddrRange int = 24
param vmSubnetName string
param loadBalancerSubnetName string
param privateDnsZoneName string

var vnetRanges = [for (spec, index) in vnetSpecs: cidrSubnet(overallAddrPrefix, regionAddrRange, index)]

module vnets './vnetRegion.bicep' = [for (spec, index) in vnetSpecs: {
  name: spec.name
  params: {
    name: spec.name
    location: spec.location
    addressRange: vnetRanges[index]
    subnets: {
      '${vmSubnetName}': cidrSubnet(vnetRanges[index], subnetAddrRange, 0)
      '${loadBalancerSubnetName}': cidrSubnet(vnetRanges[index], subnetAddrRange, 1)
    }
  }
}]

var allVnetNames = [for spec in vnetSpecs: spec.name]

module peerings 'vnetPeerings.bicep' = [for (spec, index) in vnetSpecs: if (index > 0) {
  name: '${spec.name}-peerings'
  dependsOn: vnets
  params: {
    parentVnetName: spec.name
    vnetNames: allVnetNames
    peeringCount: index
  }
}]

module privateDnsZone './privateDnsZone.bicep' = {
  name: 'private-dns-zone-${uniqueString(privateDnsZoneName)}'
  dependsOn: vnets
  params: {
    zoneName: privateDnsZoneName
    vnetLinkSpecs: [for (spec, index) in vnetSpecs: {
      vnetId: vnets[index].outputs.vnetId
      location: spec.location
    }]
  }
}

// Find available IP in each region to use for internal load balancer
output vmSubnetIds array = [for vnetName in allVnetNames: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, vmSubnetName)]
output loadBalancerSubnetIds array = [for vnetName in allVnetNames: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, loadBalancerSubnetName)]
