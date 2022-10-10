param location string = resourceGroup().location
param deploymentScriptUri string
param supportingScriptUris array

module gemRecommender '../sparkWorkspace.bicep' = {
  name: 'application'
  params: {
    location: location
  }
}

module configureDataBricks '../../Resources/cliDeploymnetScriptsUri.bicep' = {
  name: 'configureDB'
  params: {
    deploymentScriptUri: deploymentScriptUri
    supportingScriptUris: supportingScriptUris
  }
}
