@description('The location to use for the deployment script involved')
param location string

@description('The name of the Virtual Network to search')
param vnetName string

@description('The name of the specific subnet to search in')
param subnetName string

@description('The name of a managed identity having query access over the subnet')
param managedIdentityName string

@description('The resource group containing the managed identity')
param managedIdentityResourceGroup string

@description('How the deployment script should be forced to execute')
param forceUpdateTag  string = utcNow()

@allowed([
  'OnSuccess'
  'OnExpiration'
  'Always'
])
@description('When the script resource is cleaned up')
param cleanupPreference string = 'OnSuccess'

@description('Boolean that, if set to false, bypasses the script and return an empty string as IP')
param enableScript bool

resource depScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedIdentityName
  scope: resourceGroup(managedIdentityResourceGroup)
}

resource listAvailableIPs 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (enableScript) {
  name: 'ListAvailableIPs-${vnetName}-${subnetName}-${location}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${depScriptId.id}': {}
    }
  }
  kind: 'AzureCLI'
  properties: {
    forceUpdateTag: forceUpdateTag
    azCliVersion: '2.40.0'
    timeout: 'PT10M'
    retentionInterval: 'P1D'
    environmentVariables: [
      { name: 'VNET_NAME', value: vnetName }
      { name: 'SUBNET_NAME', value: subnetName }
      { name: 'RESOURCE_GROUP', value: resourceGroup().name }
    ]
    scriptContent: loadTextContent('listAvailableIPs.sh')
    cleanupPreference: cleanupPreference
  }
}

output availableIP string = enableScript ? listAvailableIPs.properties.outputs.availableIPs[0] : ''
