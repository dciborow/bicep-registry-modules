@description('Server Name for Azure database for PostgreSQL')
param serverName string = 'psql${uniqueString(resourceGroup().id)}'

@description('Database administrator login name')
@minLength(4)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for PostgreSQL compute capacity in vCores (2,4,8,16,32)')
param skuCapacity int = 2

@description('Azure database for PostgreSQL sku name ')
param skuName string = 'GP_Gen5_2'

@description('Azure database for PostgreSQL Sku Size ')
param skuSizeMB int = 51200

@description('Azure database for PostgreSQL pricing tier')
param skuTier string = 'GeneralPurpose'

@description('Azure database for PostgreSQL sku family')
param skuFamily string = 'Gen5'

@description('PostgreSQL version')
@allowed([
  '9.5'
  '9.6'
  '10'
  '11'
])
param postgresqlVersion string = '11'

@description('Location for all resources.')
param location string = resourceGroup().location
param tags object = {
  'aia-industry':                                                                     'industry'
  'aia-solution':                                                                     'solution'
  'aia-version':                                                                      '0.0'
}

@description('PostgreSQL Server backup retention days')
param backupRetentionDays int = 7

@description('Geo-Redundant Backup setting')
param geoRedundantBackup string = 'Disabled'

@description('Name of the VNet')
param vnetName string = 'vnet${uniqueString(resourceGroup().id)}'

@description('Resource group name of the VNET if using existing one.')
param vnetResourceGroupName string = resourceGroup().id

@description('Name of the subnet')
param subnetName string = 'subnet${uniqueString(resourceGroup().id)}'
param vnetEnable bool = false()

var firewallrules                                                                =  {
  batch: {
    rules: [
      {
        Name:                                                                         'AllowAzureServices'
        StartIpAddress:                                                               '0.0.0.0'
        EndIpAddress:                                                                 '0.0.0.0'
      }
    ]
  }
}

resource serverName_resource 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  tags:                                                                               tags
  name:                                                                               serverName
  location:                                                                           location
  sku: {
    name:                                                                             skuName
    tier:                                                                             skuTier
    capacity:                                                                         skuCapacity
    size:                                                                             skuSizeMB
    family:                                                                           skuFamily
  }
  properties: {
    createMode:                                                                       'Default'
    version:                                                                          postgresqlVersion
    administratorLogin:                                                               administratorLogin
    administratorLoginPassword:                                                       administratorLoginPassword
    storageProfile: {
      storageMB:                                                                      skuSizeMB
      backupRetentionDays:                                                            backupRetentionDays
      geoRedundantBackup:                                                             geoRedundantBackup
    }
  }
}

resource serverName_AllowSubnet 'Microsoft.DBforPostgreSQL/servers/virtualNetworkRules@2017-12-01' = if (vnetEnable) {
  parent:                                                                             serverName_resource
  name:                                                                               'AllowSubnet'
  properties: {
    virtualNetworkSubnetId:                                                           resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    ignoreMissingVnetServiceEndpoint:                                                 true
  }
}

@batchSize(1)
resource serverName_firewallrules_batch_rules_Name 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = [for i in range(0, length(firewallrules.batch.rules)): {
  name:                                                                               '${serverName}/${firewallrules.batch.rules[i].Name}'
  location:                                                                           location
  properties: {
    startIpAddress:                                                                   firewallrules.batch.rules[i].StartIpAddress
    endIpAddress:                                                                     firewallrules.batch.rules[i].EndIpAddress
  }
  dependsOn: [
    serverName_resource
  ]
}]

output id string                                                                 =  serverName_resource.id
