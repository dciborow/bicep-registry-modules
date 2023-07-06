param name string
param location string
param addressRange string

@description('Each key is the subnet name and the value is the subnet address range.')
param subnets object

var subnetArray = [for item in items(subnets): {
  name: item.key
  properties: {
    addressPrefix: item.value
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressRange
      ]
    }
    subnets: subnetArray
  }
}
