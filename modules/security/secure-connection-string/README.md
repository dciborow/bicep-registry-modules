#

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name                                          | Type           | Required | Description           |
| :-------------------------------------------- | :------------: | :------: | :-------------------- |
| `location`                                    | `string`       | Yes      | Deployment Location   |
| `keyVaultName`                                | `string`       | Yes      | Name of the Key Vault |
| `primaryConnectionString`                     | `bool`         | No       |                       |
| `newOrExistingCassandraDB`                    | `string`       | No       |                       |
| `cassandraDBName`                             | `string`       | No       |                       |
| `cassandraDBSecretName`                       | `string`       | No       |                       |
| `locationString`                              | `string`       | No       |                       |
| `cassandraConnectionString`                   | `securestring` | No       |                       |
| `newOrExistingCosmosDB`                       | `string`       | No       |                       |
| `cosmosDBName`                                | `string`       | No       |                       |
| `cosmosDBSecretName`                          | `string`       | No       |                       |
| `cosmosConnectionString`                      | `securestring` | No       |                       |
| `newOrExistingEventHub`                       | `string`       | No       |                       |
| `eventHubNamespaceName`                       | `string`       | No       |                       |
| `eventHubName`                                | `string`       | No       |                       |
| `eventHubAuthorizationRulesName`              | `string`       | No       |                       |
| `eventHubSecretName`                          | `string`       | No       |                       |
| `eventhubConnectionString`                    | `securestring` | No       |                       |
| `newOrExistingStorageAccount`                 | `string`       | No       |                       |
| `storageAccountName`                          | `string`       | No       |                       |
| `storageSecretName`                           | `string`       | No       |                       |
| `storageAccountConnectionString`              | `securestring` | No       |                       |
| `newOrExistingCognitiveServices`              | `string`       | No       |                       |
| `cognitiveServicesName`                       | `string`       | No       |                       |
| `cognitiveServicesSecretName`                 | `string`       | No       |                       |
| `cognitiveServicesConnectionString`           | `securestring` | No       |                       |
| `newOrExistingBatchAccount`                   | `string`       | No       |                       |
| `batchAccountName`                            | `string`       | No       |                       |
| `batchAccountSecretName`                      | `string`       | No       |                       |
| `batchAccountConnectionString`                | `securestring` | No       |                       |
| `newOrExistingRedis`                          | `string`       | No       |                       |
| `redisName`                                   | `string`       | No       |                       |
| `redisSecretName`                             | `string`       | No       |                       |
| `redisConnectionString`                       | `securestring` | No       |                       |
| `newOrExistingMapsAccount`                    | `string`       | No       |                       |
| `mapsAccountName`                             | `string`       | No       |                       |
| `mapsAccountSecretName`                       | `string`       | No       |                       |
| `mapsAccountConnectionString`                 | `securestring` | No       |                       |
| `newOrExistingOpertionalInsightsWorkspace`    | `string`       | No       |                       |
| `opertionalInsightsWorkspaceName`             | `string`       | No       |                       |
| `opertionalInsightsWorkspaceSecretName`       | `string`       | No       |                       |
| `opertionalInsightsWorkspaceConnectionString` | `securestring` | No       |                       |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

### Example 1

```bicep
param location string = 'eastus'
param cassandraDBName string = 'test-cassandra-db'
param keyVaultName string

module cassandraDBSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'cassandraDBSecret'
  params: {
    location: location
    keyVaultName: keyVaultName
    cassandraDBName: cassandraDBName
    cassandraDBSecretName: 'cassandra-db-secret'
    locationString: 'East US'
  }
}

```

### Example 2

```bicep
param location string = 'eastus'
param eventHubNamespaceName string = 'test-eventhub-namespace'
param eventHubName string = 'test-eventhub'
param eventHubAuthorizationRulesName string = 'test-eventhub-authorizationrules'
param keyVaultName string

module eventHubSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'eventHubSecret'
  params: {
    location: location
    keyVaultName: keyVaultName
    eventHubNamespaceName: eventHubNamespaceName,
    eventHubName: eventHubName,
    eventHubAuthorizationRulesName:eventHubAuthorizationRulesName,
    eventHubSecretName: 'event-hub-secret'
  }
}
```

### Example 3

```bicep
param location string = 'eastus'
param storageAccountName string = 'test-storage-account'
param keyVaultName string

module storageAccountSecrets 'br/public:security/secure-connection-string:0.0.1' = {
  name: 'storageAccountSecret'
  params: {
    location: location
    keyVaultName: keyVaultName
    storageAccountName: storageAccountName
    storageSecretName:'storage-secret'

  }
}
```
