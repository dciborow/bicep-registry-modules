param config object
var databricksWorkspaceName                                                                             =  config.resources.databricks

param location string = resourceGroup().location

param customVirtualNetworkId string = ''
param customPublicSubnetName string = 'db-pub${uniqueString(resourceGroup().id)}'
param customPrivateSubnetName string = 'db-priv${uniqueString(resourceGroup().id)}'

@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param disablePublicIp bool = false
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'
var resourceGroupName                                                                                   =  '${databricksWorkspaceName}-rg-${uniqueString(resourceGroup().id)}'

var parameters                                                                                          =  config.enable.DBVNET && config.enable.databricks ? {
  customVirtualNetworkId: {
    value:                                                                                                   customVirtualNetworkId
  }
  customPublicSubnetName: {
    value:                                                                                                   customPublicSubnetName
  }
  customPrivateSubnetName: {
    value:                                                                                                   customPrivateSubnetName
  }
  enableNoPublicIp: {
    value:                                                                                                   disablePublicIp
  }
} : {
  enableNoPublicIp: {
    value:                                                                                                   disablePublicIp
  }
}

resource databricksWorkspace 'Microsoft.Databricks/workspaces@2018-04-01' = if (newOrExisting == 'new') {
  name:                                                                                                      databricksWorkspaceName
  location:                                                                                                  location
  sku: {
    name:                                                                                                    'premium'
  }
  properties: {
    managedResourceGroupId:                                                                                  subscriptionResourceId('Microsoft.Resources/resourceGroups', resourceGroupName)
    parameters:                                                                                              parameters
  }
}

output id string                                                                                        =  databricksWorkspace.id
