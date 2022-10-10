param location string = resourceGroup().location
param identityResourceID string
param utcValue string
param deploymentScript string
param arguments string
param supportingScriptUris array

resource powershellScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'powershellScript'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityResourceID}': {}
    }
  }
  properties: {
    forceUpdateTag: '${utcValue}94'
    azPowerShellVersion: '3.0'
    primaryScriptUri: deploymentScript
    arguments: arguments
    supportingScriptUris: supportingScriptUris
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
