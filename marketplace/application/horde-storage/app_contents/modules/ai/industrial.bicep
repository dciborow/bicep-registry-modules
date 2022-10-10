param location                  string = resourceGroup().location

module forecasting 're-forecast.bicep' = {
  name: 'forecasting'
  params: {
    location: location
  }
}

module recommender 're-reco.bicep' = {
  name: 'recommender'
  params: {
    location: location
  }
}
