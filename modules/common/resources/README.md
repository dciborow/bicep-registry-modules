#

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name                          | Type     | Required | Description                                   |
| :---------------------------- | :------: | :------: | :-------------------------------------------- |
| `location`                    | `string` | Yes      | Deployment Location                           |
| `isZoneRedundant`             | `bool`   | No       | Toggle to enable or disable zone redudance.   |
| `enableVirtualNetwork`        | `bool`   | No       | Toggle to enable or disable virtual networks. |
| `newOrExistingStorageAccount` | `string` | No       |                                               |
| `storageAccountPrefix`        | `string` | No       |                                               |
| `storageAccountName`          | `string` | No       |                                               |
| `storageResourceGroupName`    | `string` | No       |                                               |
| `storageProperties`           | `object` | No       |                                               |
| `newOrExistingCosmosDB`       | `string` | No       |                                               |
| `cosmosDBPrefix`              | `string` | No       |                                               |
| `cosmosDBName`                | `string` | No       |                                               |
| `cosmosDBResourceGroupName`   | `string` | No       |                                               |
| `cosmosDBProperties`          | `object` | No       |                                               |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

### Example 1
Deploy Storage Account
```bicep

param location string = resourceGroup().location

module storageAccount 'br/public:common/resources:1.0.1' = {
  name: 'deployStorage'
  params: {
    location: location
    newOrExistingStorageAccount: 'new'
  }
}

```

### Example 2
Deploy a Storage Account and Cosmos DB into the same Virtual Network

```bicep
param location string = resourceGroup().location

module storageAccount 'br/public:common/resources:1.0.1' = {
  name: 'deployStorage'
  params: {
    location: location
    newOrExistingStorageAccount: 'new'
    newOrExistingCosmosDB: 'new'
    enableVirtualNetwork: true
  }
}

```