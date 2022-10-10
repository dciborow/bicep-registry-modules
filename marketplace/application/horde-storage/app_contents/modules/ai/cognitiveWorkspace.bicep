param   location          string  = resourceGroup().location
param   enableVNet        bool    = false

module  workspace_config './configuration.bicep' = {
  name: 'configureDeployment'
  params: {
    location:           location
    enableVNet:         enableVNet
    enableStorage:      true
    enableKeyVault:     true
    enableAppInsights:  true
    enableML:           true
    enableCogService:   true
  }
}
module resources '../resources.bicep' = {
  name: 'resources'
  params: {
    config: workspace_config.outputs.configuration
  }
}
