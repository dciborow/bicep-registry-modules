@description('Array of objects, each one having a name and location')
param vnetSpecs array

param overallAddrPrefix string
param regionAddrRange int
param vmSubnetName string

var vnetRanges = [for (spec, index) in vnetSpecs: cidrSubnet(overallAddrPrefix, regionAddrRange, index)]

module vnets './vnet-region.bicep' = [for (spec, index) in vnetSpecs: {
  name: spec.name
  params: {
    name: spec.name
    location: spec.location
    addressRange: vnetRanges[index]
    subnets: {
      '${vmSubnetName}': cidrSubnet(vnetRanges[index], 24, 0)
    }
  }
}]

var allVnetNames = [for spec in vnetSpecs: spec.name]

module peerings 'vnet-peerings.bicep' = [for (spec, index) in vnetSpecs: if (index > 0) {
  name: '${spec.name}-peerings'
  dependsOn: vnets
  params: {
    parentVnetName: spec.name
    vnetNames: allVnetNames
    peeringCount: index
  }
}]

output vmSubnetIds array = [for vnetName in allVnetNames: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, vmSubnetName)]
