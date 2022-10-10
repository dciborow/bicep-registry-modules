@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

param subnetID string = ''
param config object = {
  'location':                      resourceGroup().location
  'tags': {
    'aia-industry':                'industry'
    'aia-solution':                'solution'
    'aia-version':                 '0.0'
  }
  'uniqueKey':                     uniqueString(resourceGroup().id)
}

var storageAccountType        =  'Standard_LRS'

var networkAcls               =  config.enable.vNET ? {
  defaultAction:                   'Deny'
  virtualNetworkRules: [
    {
      action:                      'Allow'
      id:                          subnetID
    }
  ]
} : {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = if (newOrExisting == 'new') {
  tags:                            config.tags
  name:                            uniqueString(resourceGroup().id)
  location:                        resourceGroup().location
  sku: {
    name:                          storageAccountType
  }
  kind:                            'StorageV2'
  properties: {
    encryption: {
      keySource:                   'Microsoft.Storage'
      services: {
        blob: {
          enabled:                 true
        }
        file: {
          enabled:                 true
        }
      }
    }
    supportsHttpsTrafficOnly:      true
    allowBlobPublicAccess:         false
    networkAcls:                   networkAcls
    minimumTlsVersion:             'TLS1_2'
  }
}

output id string              =  storageAccount.id
