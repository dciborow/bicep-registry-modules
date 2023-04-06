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