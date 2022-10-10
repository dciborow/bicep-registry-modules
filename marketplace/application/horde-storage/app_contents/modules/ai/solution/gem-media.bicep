param   location          string  = resourceGroup().location
param   enableVNet        bool    = false

module  workspace_config '../configuration.bicep' = {
  name: 'configureDeployment'
  params: {
location:            location
    enableAppInsights:   true
    enableStorage:       true
    enableVNet:          enableVNet
    enableKeyVault:      true
    enableML:            true
    enableWebsite:       true
    enableServerFarms:   true
    enableManagedId:     true
    enableContainerReg:  true
  }
}


module resources '../../resources.bicep' = {
  name: 'resources'
  params: {
    config: workspace_config.outputs.configuration
  }
}
