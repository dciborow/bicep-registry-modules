param config object = {
  'location': resourceGroup().location
  'tags': {
    'aia-industry': 'industry'
    'aia-solution': 'solution'
    'aia-version': '0.0'
  }
}

param utcValue string = utcNow()
param deploymentScriptUri string
param supportingScriptUris array

param arguments string = ''

var identityName = 'scratch${uniqueString(resourceGroup().id)}'
var roleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var roleAssignmentName = guid(identityName, roleDefinitionId)

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: config.location
}

resource identityRoleAssignDeployment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: resourceGroup()
  name: roleAssignmentName
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'script${uniqueString(resourceGroup().id)}'
  tags: config.tags
  location: config.location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    forceUpdateTag: '${utcValue}94'
    azCliVersion: '2.9.1'
    primaryScriptUri: deploymentScriptUri
    supportingScriptUris: supportingScriptUris
    arguments: arguments
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
