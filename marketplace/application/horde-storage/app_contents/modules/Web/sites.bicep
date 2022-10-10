param config object = {
  'location': resourceGroup().location
  'tags': {
    'aia-industry': 'industry'
    'aia-solution': 'solution'
    'aia-version': '0.0'
  }
  'enable': {
    'vNET': false
  }
  'resources': {
    'website': 'website${uniqueString(resourceGroup().id)}'
  }
}

@description('Describes plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param skuName string = 'F1'

@description('Describes plan\'s instance count')
@minValue(1)
@maxValue(3)
param skuCapacity int = 1

param subnetID string = ''

var ipSecurityRestrictions = config.enable.vNET ? [
  {
    vnetSubnetResourceId: subnetID
    action: 'Allow'
    tag: 'Default'
    priority: 1
    name: 'allowinboundonlyfromvnet'
    description: 'Allowing inbound only from VNET'
  }
  {
    ipAddress: 'AzureCognitiveSearch'
    tag: 'ServiceTag'
    action: 'Allow'
    priority: 2
    name: 'allowsearchinbound'
    description: 'allow search inbound from webapps'
  }
] : []
var scmIpSecurityRestrictions = config.enable.vNET ? [
  {
    vnetSubnetResourceId: subnetID
    action: 'Allow'
    tag: 'Default'
    priority: 1
    name: 'allowscminboundonlyfromvnet'
    description: 'Allowing scm inbound only from VNET'
  }
  {
    ipAddress: 'AzureCognitiveSearch'
    tag: 'ServiceTag'
    action: 'Allow'
    priority: 2
    name: 'allowsearchinbound'
    description: 'allow search inbound from webapps'
  }
] : []

var linuxFxVersion = 'PYTHON|3.7'

module hostingPlanName 'serverfarms.bicep' = {
  name: 'host${config.resources.website}'
  params: {
    config: config
    skuName: skuName
    skuCapacity: skuCapacity
  }
} 
resource webSite 'Microsoft.Web/sites@2020-12-01' = {
  name: config.resources.website
  location: config.location
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/host${config.resources.website}': 'Resource'
    displayName: 'Website'
  }
  properties: {
    name: config.resources.website
    serverFarmId: hostingPlanName.outputs.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      ipSecurityRestrictions: ipSecurityRestrictions
      scmIpSecurityRestrictions: scmIpSecurityRestrictions
    }
  }
}
output id string = webSite.id
