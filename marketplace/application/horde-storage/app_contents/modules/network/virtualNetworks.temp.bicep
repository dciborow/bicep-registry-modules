param  config                       object  = { 
  'location':                            resourceGroup().location
  'tags': {
    'aia-industry':                      'industry'
    'aia-solution':                      'solution'
    'aia-version':                       '0.0'
  }
  'uniqueKey':                           uniqueString(resourceGroup().id)
}
param  name                         string  = uniqueString(resourceGroup().id) 

@allowed([
  'AutoApproval'
  'ManualApproval'
  'none'
])
param  privateEndpointType          string  = 'none' 

@description('Determines whether or not a new VNet should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param  vnetOption                   string  = 'new' 

@allowed([
  'new'
  'existing'
  'none'
])
param  subnetOption                 string  = (((!(privateEndpointType == 'none')) || (vnetOption == 'new')) ? 'new' : 'none') 
param  vnetName                     string  = 'vnet${uniqueString(resourceGroup().id, name)}' 
param  subnetName                   string  = 'subnet${uniqueString(resourceGroup().id, name)}' 

param  addressPrefixes              array   = [ 
  '10.0.0.0/16'
]
param  subnetPrefix                 string  = '10.0.0.0/24' 
param  databricksPublicSubnetCidr   string  = '10.0.1.0/24' 
param  databricksPrivateSubnetCidr  string  = '10.0.2.0/24' 
param  cogServiceSubnetCidr         string  = '10.0.3.0/24' 

var serviceEndpointsAll = [
  {
    service:                             'Microsoft.Storage'
  }
  {
    service:                             'Microsoft.KeyVault'
  }
]
var location = config.location
var tags = config.tags

resource vnet                       'Microsoft.Network/virtualNetworks@2020-06-01'          = if (vnetOption == 'new') {
  name:                                  vnetName
  location:                              location
  tags:                                  tags
  properties: {
    addressSpace: {
      addressPrefixes:                   addressPrefixes
    }
    enableDdosProtection:                false
    enableVmProtection:                  false
  }
}
resource subnet                     'Microsoft.Network/virtualNetworks/subnets@2020-06-01'  = if (subnetOption == 'new') {
  parent:                                vnet
  name:                                  subnetName
  properties: {
    addressPrefix:                       subnetPrefix
    privateEndpointNetworkPolicies:      'Disabled'
    privateLinkServiceNetworkPolicies:   'Enabled'
    serviceEndpoints:                    serviceEndpointsAll
  }
}
resource defaultNsgName             'Microsoft.Network/networkSecurityGroups@2020-05-01'    = {
  location:                              location
  name:                                  'defaultNsgName'
}
resource databricksNsgId            'Microsoft.Network/networkSecurityGroups@2020-05-01'    = if (config.enable.DBVNET && config.enable.databricks) {
  location:                              location
  name:                                  'databricksNsgName'
  properties: {
    securityRules: [
      {
        name:                            'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
        properties: {
          description:                   'Required for worker nodes communication within a cluster.'
          protocol:                      '*'
          sourcePortRange:               '*'
          destinationPortRange:          '*'
          sourceAddressPrefix:           'VirtualNetwork'
          destinationAddressPrefix:      'VirtualNetwork'
          access:                        'Allow'
          priority:                      100
          direction:                     'Inbound'
        }
      }
      {
        name:                            'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp'
        properties: {
          description:                   'Required for workers communication with Databricks Webapp.'
          protocol:                      'Tcp'
          sourcePortRange:               '*'
          destinationPortRange:          '443'
          sourceAddressPrefix:           'VirtualNetwork'
          destinationAddressPrefix:      'AzureDatabricks'
          access:                        'Allow'
          priority:                      100
          direction:                     'Outbound'
        }
      }
      {
        name:                            'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql'
        properties: {
          description:                   'Required for workers communication with Azure SQL services.'
          protocol:                      'Tcp'
          sourcePortRange:               '*'
          destinationPortRange:          '3306'
          sourceAddressPrefix:           'VirtualNetwork'
          destinationAddressPrefix:      'Sql'
          access:                        'Allow'
          priority:                      101
          direction:                     'Outbound'
        }
      }
      {
        name:                            'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage'
        properties: {
          description:                   'Required for workers communication with Azure Storage services.'
          protocol:                      'Tcp'
          sourcePortRange:               '*'
          destinationPortRange:          '443'
          sourceAddressPrefix:           'VirtualNetwork'
          destinationAddressPrefix:      'Storage'
          access:                        'Allow'
          priority:                      102
          direction:                     'Outbound'
        }
      }
      {
        name:                            'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound'
        properties: {
          description:                   'Required for worker nodes communication within a cluster.'
          protocol:                      '*'
          sourcePortRange:               '*'
          destinationPortRange:          '*'
          sourceAddressPrefix:           'VirtualNetwork'
          destinationAddressPrefix:      'VirtualNetwork'
          access:                        'Allow'
          priority:                      103
          direction:                     'Outbound'
        }
      }
      {
        name:                            'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub'
        properties: {
          description:                   'Required for worker communication with Azure Eventhub services.'
          protocol:                      'Tcp'
          sourcePortRange:               '*'
          destinationPortRange:          '9093'
          sourceAddressPrefix:           'VirtualNetwork'
          destinationAddressPrefix:      'EventHub'
          access:                        'Allow'
          priority:                      104
          direction:                     'Outbound'
        }
      }
    ]
  }
  dependsOn: [
    defaultNsgName
  ]
}
resource databricksPublicSubnet     'Microsoft.Network/virtualNetworks/subnets@2020-05-01'  = if (config.enable.DBVNET && config.enable.databricks) {
  parent:                                vnet
  location:                              location
  name: 'db-pub${uniqueString(resourceGroup().id)}'
  properties: {
    addressPrefix:                       databricksPublicSubnetCidr
    networkSecurityGroup: {
      id:                                databricksNsgId.id
    }
    delegations: [
      {
        name:                            'databricks-del-public'
        properties: {
          serviceName:                   'Microsoft.Databricks/workspaces'
        }
      }
    ]
  }
  dependsOn: [
    subnet
  ]
}
resource databricksPrivateSubnet    'Microsoft.Network/virtualNetworks/subnets@2020-05-01'  = if (config.enable.DBVNET && config.enable.databricks) {
  parent:                                vnet
  location:                              location
  name: 'db-priv${uniqueString(resourceGroup().id)}'
  properties: {
    addressPrefix:                       databricksPrivateSubnetCidr
    networkSecurityGroup: {
      id:                                databricksNsgId.id
    }
    delegations: [
      {
        name:                            'databricks-del-private'
        properties: {
          serviceName:                   'Microsoft.Databricks/workspaces'
        }
      }
    ]
  }
  dependsOn: [
    databricksPublicSubnet
  ]
}
resource cogService_subnet          'Microsoft.Network/virtualNetworks/subnets@2020-05-01'  = if (config.enable.cogService) {
  parent:                                vnet
  location:                              location
  name:                                  config.resources.cogServiceSubnet
  properties: {
    addressPrefix:                       cogServiceSubnetCidr
    networkSecurityGroup: {
      id:                                defaultNsgName.id
    }
    
  }
  dependsOn: [
    subnet
  ]
}

output private_vnet_id         string = config.enable.DBVNET && config.enable.databricks ? databricksPrivateSubnet.id :  ''
output public_vnet_id          string = config.enable.DBVNET && config.enable.databricks ? databricksPublicSubnet.id  :  ''
output subnet_id               string = subnet.id
output vnet_id                 string = vnet.id
output vnet                    object = vnet
output subnet                  object = subnet
output cog_service_subnet_id   string = config.enable.cogService ? cogService_subnet.id :  '' 
