param location string
param keyVaultName string
param tenantId string = subscription().tenantId

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: tenantId
  }
}

output id string = keyVault.id
output name string = keyVault.name
