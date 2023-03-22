@description('Deployment Location')
param location string

@description('Resource Group Name')
param resourceGroupName string = resourceGroup().name

@description('Public IP Resource Prefix')
param prefix string = 'pip'

@description('PublicIP Resource Name')
param name string = '${prefix}${uniqueString(resourceGroup().id)}'

@description('If this is true, dnsZoneName, etc. should be specified')
param useDnsZone bool = false

@description('Specifies the name of the DNS zone to be used for the DNS record.')
param dnsZoneName string = ''

@description('Specifies the name of the resource group containing the DNS zone.')
param dnsZoneResourceGroupName string = resourceGroup().name

@description('Specifies the suffix to be used for the DNS record name. For example, if this parameter is set to "frontend", and the DNS zone name is "example.com", the resulting DNS record name will be "frontend.example.com".')
param dnsRecordNameSuffix string = ''

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

@description('The subscription containing an existing dns zone')
param subscriptionId string = subscription().subscriptionId

module newPublicIP 'modules/publicIPAddresses.bicep' = if (newOrExisting == 'new') {
  name: 'new-pip-${uniqueString(location, resourceGroup().id, deployment().name)}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    name: name
    publicIpSku: publicIpSku
    publicIpAllocationMethod: publicIpAllocationMethod
    publicIpDns: publicIpDns
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-03-01' existing = {
  name: name
  scope: resourceGroup(subscriptionId, resourceGroupName)
}

module dnsRecord 'modules/dnsZoneARecord.bicep' = if (useDnsZone) {
  name: 'dns-ip-${uniqueString(location, resourceGroup().id, deployment().name)}'
  scope: resourceGroup(subscriptionId, dnsZoneResourceGroupName)
  params: {
    dnsZoneName: dnsZoneName
    recordName: '${location}.${dnsRecordNameSuffix}'
    ipAddress: publicIP.properties.ipAddress
  }
}

@description('Public IP Id')
output id string = publicIP.id

@description('Public IP Name')
output name string = publicIP.name

@description('Public IP Address')
output ipAddress string = publicIP.properties.ipAddress
