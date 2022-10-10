param   location          string  = resourceGroup().location
param   enableVNet        bool    = false

module  workspace_config '../configuration.bicep' = {
  name: 'configureDeployment'
  params: {
    location:            location
    enableAppInsights:   false
    enableStorage:       false
    enableVNet:          enableVNet
    enableKeyVault:      false
    enableSearch:        false
    enableML:            false
    enableMLCompute:     false
    enableDatabricks:    false
    enableCosmosDB:      false
    enableCogService:    false
    enabledbvnet:        false
    enableMLAKS:         false
    enableaksvnet:       false
    enableWebsite:       false
    enablePSQL:          false
  }
}


module resources '../../resources.bicep' = {
  name: 'resources'
  params: {
    config: workspace_config.outputs.configuration
  }
}
