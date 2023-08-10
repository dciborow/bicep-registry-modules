// All peerings for a specific vnet.

@description('The name of the parent vnet, assumed to be in the same resource group')
param parentVnetName string

@description('Array of vnet names to peer with in same resource group, only first peeringCount will be used to peer')
param vnetNames array

@description('Index of one past the last vnet to peer with')
param peeringCount int

module peeringPairs './vnetPeeringPair.bicep' = [for index in range(0, peeringCount): {
  name: 'peering-${index}-${peeringCount}'
  params: {
    srcVnetName: vnetNames[index]
    dstVnetName: parentVnetName
  }
}]
