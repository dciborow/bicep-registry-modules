@description('An existing Private DNS Zone resource name')
param privateDnsZoneName string

@description('Name of A record to add to dnsZoneName')
param recordName string

@description('IP Address to add as A record')
param ipAddress string

resource zone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource record 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: zone
  name: recordName
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: ipAddress
      }
    ]
  }
}

