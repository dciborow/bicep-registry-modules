#

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name                                          | Type           | Required | Description                                               |
| :-------------------------------------------- | :------------: | :------: | :-------------------------------------------------------- |
| `location`                                    | `string`       | Yes      | Deployment Location                                       |
| `keyVaultName`                                | `string`       | Yes      | Name of the Key Vault                                     |
| `primaryConnectionString`                     | `bool`         | No       | Primary connection string                                 |
| `newOrExistingCassandraDB`                    | `string`       | No       |                                                           |
| `cassandraDBName`                             | `string`       | No       | Name of the Cassandra DB                                  |
| `cassandraDBSecretName`                       | `string`       | No       | Name of the secret for the Cassandra DB                   |
| `locationString`                              | `string`       | No       | Custom Location String for Cassandra DB                   |
| `cassandraConnectionString`                   | `securestring` | No       | Connection string for the Cassandra DB                    |
| `newOrExistingCosmosDB`                       | `string`       | No       |                                                           |
| `cosmosDBName`                                | `string`       | No       | Name of the Cosmos DB                                     |
| `cosmosDBSecretName`                          | `string`       | No       | Name of the secret for the Cosmos DB                      |
| `cosmosConnectionString`                      | `securestring` | No       | Connection string for the Cosmos DB                       |
| `newOrExistingEventHub`                       | `string`       | No       |                                                           |
| `eventHubNamespaceName`                       | `string`       | No       | Name of the Event Hub Namespace                           |
| `eventHubName`                                | `string`       | No       | Name of the Event Hub                                     |
| `eventHubAuthorizationRulesName`              | `string`       | No       | Name of the secret for the Event Hub                      |
| `eventHubSecretName`                          | `string`       | No       | Name of the secret for the Event Hub                      |
| `eventhubConnectionString`                    | `securestring` | No       | Connection string for the Event Hub                       |
| `newOrExistingStorageAccount`                 | `string`       | No       |                                                           |
| `storageAccountName`                          | `string`       | No       | Name of the Storage Account                               |
| `storageSecretName`                           | `string`       | No       | Name of the secret for the Storage Account                |
| `storageAccountConnectionString`              | `securestring` | No       | Connection string for the Storage Account                 |
| `newOrExistingCognitiveServices`              | `string`       | No       |                                                           |
| `cognitiveServicesName`                       | `string`       | No       | Name of the Cognitive Services Account                    |
| `cognitiveServicesSecretName`                 | `string`       | No       | Name of the secret for the Cognitive Services Account     |
| `cognitiveServicesConnectionString`           | `securestring` | No       | Connection string for the Cognitive Services Account      |
| `newOrExistingBatchAccount`                   | `string`       | No       |                                                           |
| `batchAccountName`                            | `string`       | No       | Name of the Batch Account                                 |
| `batchAccountSecretName`                      | `string`       | No       | Name of the secret for the Batch Account                  |
| `batchAccountConnectionString`                | `securestring` | No       | Connection string for the Batch Account                   |
| `newOrExistingRedis`                          | `string`       | No       |                                                           |
| `redisName`                                   | `string`       | No       | Name of the Redis Account                                 |
| `redisSecretName`                             | `string`       | No       | Name of the secret for the Redis Account                  |
| `redisConnectionString`                       | `securestring` | No       | Connection string for the Redis Account                   |
| `newOrExistingMapsAccount`                    | `string`       | No       |                                                           |
| `mapsAccountName`                             | `string`       | No       | Name of the Maps Account                                  |
| `mapsAccountSecretName`                       | `string`       | No       | Name of the secret for the Maps Account                   |
| `mapsAccountConnectionString`                 | `securestring` | No       | Connection string for the Maps Account                    |
| `newOrExistingOpertionalInsightsWorkspace`    | `string`       | No       |                                                           |
| `opertionalInsightsWorkspaceName`             | `string`       | No       | Name of the Operational Insights Workspace                |
| `opertionalInsightsWorkspaceSecretName`       | `string`       | No       | Name of the secret for the Operational Insights Workspace |
| `opertionalInsightsWorkspaceConnectionString` | `securestring` | No       | Connection string for the Operational Insights Workspace  |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples
### Example 0
Create a Key Vault and a Storage Account.
Then, insert the primaryConnectionString for the Storage Account into the Key Vault.

```bicep
param location string = 'eastus'
param keyVaultName string = 'test-key-vault'
param storageAccountName string = 'test-storage-account'

module keyVault 'br/public:security/key-vault:0.0.1' = {
  name: 'keyvault-${guid(resourceGroup().id, location, keyVaultName)}'
  params: {
    location: location
    name: keyVaultName
  }
}

module storageAccount 'br/public:storage/storage-account:0.0.1' = {
  name: 'storageaccount-${guid(resourceGroup().id, location, storageAccountName)}'
  params: {
    location: location
    name: storageAccountName
  }
}

module storageAccountSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'insertSecrets-${guid(resourceGroup().id, location, keyVaultName, storageAccountName)}'
  params: {
    location: location
    keyVaultName: keyVault.outputs.name
    storageAccountName: storageAccount.outputs.name
  }
}
```

### Example 1
Create a Key Vault and a Storage Account.
Then, insert the primaryConnectionString for the Storage Account into the Key Vault.

```bicep
param location string = 'eastus'
param keyVaultName string = 'test-key-vault'
param storageAccountName string = 'test-storage-account'

module keyVault 'br/public:security/key-vault:0.0.1' = {
  name: 'keyvault-${guid(resourceGroup().id, location, keyVaultName)}'
  params: {
    location: location
    name: keyVaultName
  }
}

module storageAccount 'br/public:storage/storage-acount:0.0.1' = {
  name: 'storageaccount-${guid(resourceGroup().id, location, storageAccountName)}'
  params: {
    location: location
    name: storageAccountName
  }
}

module storageAccountSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'insertSecrets-${guid(resourceGroup().id, location, keyVaultName, storageAccountName)}'
  params: {
    location: location
    keyVaultName: keyVault.outputs.name
    storageAccountName: storageAccount.outputs.name
  }
}
```

### Example 2a
Insert the secret of a newly created resource using Bicep modules.

```bicep
param location string = 'eastus'
param keyVaultName string = 'test-key-vault'
param cassandraDBName string = 'test-cassandra-db'

module keyVault 'br/public:security/key-vault:0.0.1' = {
  name: 'keyvault-${guid(resourceGroup().id, location, keyVaultName)}'
  params: {
    location: location
    name: keyVaultName
  }
}

module cassandraDB 'br/public:security/key-vault:0.0.1' = {
  name: 'keyvault-${guid(resourceGroup().id, location, cassandraDBName)}'
  params: {
    location: location
    name: cassandraDBName
    enableCassandra: true
  }
}

module cassandraDBSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'cassandraDBSecret-${guid(resourceGroup().id, location, keyVaultName, cassandraDBName)}'
  params: {
    location: location
    keyVaultName: keyVault.outputs.name
    cassandraDBName: cassandraDB.outputs.name
    cassandraDBSecretName: 'cassandra-db-secret'
    locationString: '${location}.cassandra.cosmos.azure.com'
  }
}

```

### Example 2b
Insert the secret of a newly created resource using Bicep resources.

```bicep
param location string = 'eastus'
param keyVaultName string = 'test-key-vault'
param cassandraDBName string = 'test-cassandra-db'

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: 'keyvault-${guid(resourceGroup().id, location, keyVaultName)}'
  location: location
  properties: {
    name: keyVaultName
  }
}

resource cassandraDB 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: cassandraDBName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    capabilities: { name: 'EnableCassandra' }
  }
}

module cassandraDBSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'cassandraDBSecret'
  params: {
    location: location
    keyVaultName: keyVault.outputs.name
    cassandraDBName: cassandraDB.name
    cassandraDBSecretName: 'cassandra-db-secret'
    locationString: 'East US'
  }
}

```


### Example 3
Insert a secret manually.

```bicep
param location string = 'eastus'
param cassandraDBName string = 'test-cassandra-db'
param cassandraDBResourceGroup string = resourceGroup().name
param keyVaultName string

@secure
param cassandraConnectionString string

module cassandraDBSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'cassandraDBSecret'
  params: {
    location: location
    keyVaultName: keyVaultName
    cassandraDBSecretName: 'cassandra-db-secret'
    cassandraConnectionString: cassandraConnectionString
  }
}

```

### Example 4
Insert the secret of using a previously created resource.

```bicep
param location string = 'eastus'
param cassandraDBName string = 'test-cassandra-db'
param cassandraDBResourceGroup string = resourceGroup().name
param keyVaultName string

resource cassandraDB 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = {
  scope: resourceGroup(cassandraDBResourceGroup)
  name: cassandraDBName
}

var cassandraDBKey = listKeys().primaryMasterKey
var cassandraConnectionString = 'Contact Points=${cassandraDBName}.cassandra.cosmos.azure.com,${location}.cassandra.cosmos.azure.com;Username=${cassandraDBName};Password=${cassandraDBKey};Port=10350'

module cassandraDBSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'cassandraDBSecret'
  params: {
    location: location
    keyVaultName: keyVaultName
    cassandraConnectionString: cassandraConnectionString
  }
}

```


### Example 5

```bicep
param location string = 'eastus'
param eventHubNamespaceName string = 'test-eventhub-namespace'
param eventHubName string = 'test-eventhub'
param eventHubAuthorizationRulesName string = 'test-eventhub-authorizationrules'
param keyVaultName string

module eventHubs 'br/public:eventhub/eventhubs:0.0.1' = {
  name: 'myeventhubs'
  params: {
    location: location
    eventHubNamespaceName: eventHubNamespaceName
    eventHubName: eventHubName
    eventHubAuthorizationRulesName: eventHubAuthorizationRulesName
  }
}

module eventHubSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'eventHubSecret'
  params: {
    location: location
    keyVaultName: keyVaultName
    eventHubNamespaceName: eventHubs.outputs.namespaceName,
    eventHubName: eventHubs.outputs.name,
    eventHubAuthorizationRulesName:eventHubs.outputs.authorizationRulesName,
  }
}
```

