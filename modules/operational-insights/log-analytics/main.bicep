@description('Specify the location for the workspace.')
param location string

@description('Log Analytics Workspace Name Prefix')
param prefix string = 'log'

@description('Specify the name of the workspace.')
param name string = '${prefix}-${uniqueString(resourceGroup().id)}}'

@description('Create new or use existing workspace')
@allowed([ 'new', 'existing' ])
param newOrExisting string = 'new'

@description('The subscription containing an existing log analytics workspace')
param existingSubscriptionId string = subscription().subscriptionId

@description('The resource group containing an existing logAnalyticsWorkspaceName')
param existingLogAnalyticsWorkspaceResourceGroupName string = resourceGroup().name

@description('Specify the pricing tier: PerGB2018 or legacy tiers (Free, Standalone, PerNode, Standard or Premium) which are not available to all customers.')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param sku string = 'PerGB2018'

@description('Specify the number of days to retain data.')
param retentionInDays int = 30

@description('Specify true to use resource or workspace permissions, or false to require workspace permissions.')
param resourcePermissions bool = true

resource newWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = if (newOrExisting == 'new') {
  name: name
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: resourcePermissions
    }
  }
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: name
  scope: resourceGroup(existingSubscriptionId, existingLogAnalyticsWorkspaceResourceGroupName)
}

@description('The Log Analytics Workspace ID.')
output id string = workspace.id

@description('The Log Analytics Workspace Name.')
output name string = workspace.name
