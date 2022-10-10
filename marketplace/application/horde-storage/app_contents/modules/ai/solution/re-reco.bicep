param location string = resourceGroup().location
param enableVNet bool = true

module recommender '../sparkWorkspace.bicep' = {
  name: 'application'
  params: {
    location: location
    enableVNet: enableVNet
    enableCosmosDB: true
  }
}
