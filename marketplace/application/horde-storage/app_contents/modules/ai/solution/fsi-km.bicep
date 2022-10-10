param   location          string  = resourceGroup().location
param   enableVNet        bool    = false

module  workspace_config '../configuration.bicep' = {
    location:            location
    enableAppInsights:   true
    enableStorage:       true
    enableVNet:          enableVNet
    enableKeyVault:      true
    enableML:            true
    enableCogService:    true
    enableWebsite:       true
    enableContainerReg:  true
  }
}


module resources '../../resources.bicep' = {
  name: 'resources'
  params: {
    config: workspace_config.outputs.configuration
  }
}
