@description('Deployment Location')
param location string

@description('Resource Group Name')
param resourceGroupName string = resourceGroup().name

@description('Public IP Resource Prefix')
param prefix string = 'pip'

@description('PublicIP Resource Name')
param name string = '${prefix}${uniqueString(resourceGroup().id)}'

@allowed([ 'new', 'existing'])
@description('Create new or use existing resource selection. new/existing')
param newOrExisting string = 'new'

@description('Specifies the SKU (stock-keeping unit) of the public IP address.')
param publicIpSku object = {
  name: 'Standard'
  tier: 'Regional'
}

@allowed([ 'Static', 'Dynamic'])
@description('Specifies the allocation method of the public IP address. Possible values are Static or Dynamic.')
param publicIpAllocationMethod string = 'Static'

@description('Specifies the domain name label for the public IP address.')
param publicIpDns string = 'dns-${uniqueString(resourceGroup().id, name)}'

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-03-01' = if (newOrExisting == 'new') {
  name: name
  sku: publicIpSku
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
    dnsSettings: {
      domainNameLabel: toLower(publicIpDns)
    }
  }
}
