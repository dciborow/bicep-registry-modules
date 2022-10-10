param   location          string  = resourceGroup().location
param   enableCosmosDB    bool    = false

// param   create_deployment bool    = true
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
    enableDatabricks:   true
    enableCosmosDB:     enableCosmosDB
    enabledbvnet:       true
    enableMLAKS:        false
  }
}


module resources '../resources.bicep' = {
  name: 'resources'
  params: {
    // location: location
    config: workspace_config.outputs.configuration
  }
}
