param location string = resourceGroup().location
param enableVNet bool = true

module forecasting '../sparkWorkspace.bicep' = {
  name: 'application'
  params: {
    location: location
    enableVNet:          enableVNet
    enableManagedId:     true
    }
}
