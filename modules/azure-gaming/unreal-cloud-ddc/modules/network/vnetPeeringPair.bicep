param srcVnetName string

param dstVnetName string

resource srcVnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: srcVnetName
}

resource dstVnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: dstVnetName
}

resource srcToDstPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${srcVnetName}-To-${dstVnetName}'
  parent: srcVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
   remoteVirtualNetwork: {
      id: dstVnet.id
    }
  }
}

resource dstToSrcPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${dstVnetName}-To-${srcVnetName}'
  parent: dstVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: srcVnet.id
    }
  }
}
