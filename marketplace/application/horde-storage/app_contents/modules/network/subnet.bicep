param config object = {
  'location': resourceGroup().location
  'tags': {
    'aia-industry': 'industry'
    'aia-solution': 'solution'
    'aia-version': '0.0'
  }
  'uniqueKey': uniqueString(resourceGroup().id)
}
param name string = uniqueString(resourceGroup().id)

@allowed([
  'AutoApproval'
  'ManualApproval'
  'none'
])
param privateEndpointType string = 'none'

@description('Determines whether or not a new VNet should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param vnetOption string = 'new'

@description('Determines whether or not a new subnet should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param subnetOption string = (((!(privateEndpointType == 'none')) || (vnetOption == 'new')) ? 'new' : 'none')

@description('Name of the VNet')
param vnetName string = 'vnet${uniqueString(resourceGroup().id, name)}'

@description('Address prefix of the virtual network')
param addressPrefixes array = [
  '10.0.0.0/16'
]

@description('Name of the subnet')
param subnetName string = 'subnet${uniqueString(resourceGroup().id, name)}'

@description('Subnet prefix of the virtual network')
param subnetPrefix string = '10.0.0.0/24'

var serviceEndpointsAll = [
  {
    service: 'Microsoft.Storage'
  }
  {
    service: 'Microsoft.KeyVault'
  }
]
var location  = config.location
var tags      = config.tags

resource vnet    'Microsoft.Network/virtualNetworks@2020-06-01'        = if (vnetOption == 'new') {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = if (subnetOption == 'new') {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: subnetPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    serviceEndpoints: serviceEndpointsAll
  }
}

output vnet_id    string = vnet.id
output subnet_id  string = subnet.id
output vnet       object = vnet
output subnet     object = subnet
