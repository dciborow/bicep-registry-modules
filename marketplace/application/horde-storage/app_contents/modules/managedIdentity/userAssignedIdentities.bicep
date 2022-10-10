param config object = {
  'location': resourceGroup().location
}

param identityName string = 'scratch'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: config.location
}
output id string = managedIdentity.id
