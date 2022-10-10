@description('Product ID of Application.')
param name string = 'pid-7837dd60-4ba8-419a-a26f-237bbe170773-partnercenter'

resource partnercenter 'Microsoft.Resources/deployments@2020-06-01' = {
  name: name
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

output id string = partnercenter.id