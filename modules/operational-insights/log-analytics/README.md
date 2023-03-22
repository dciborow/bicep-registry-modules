# Log Analytics Workspace

Bicep module for creating a Azure Log Analytics Workspace.

## Description

This is a bicep template that can be used to create or use an existing Log Analytics Workspace in Azure.
The template requires input parameters to specify the location, prefix, name, new or existing workspace, subscription ID, resource group name, pricing tier, retention period, and resource permissions.
The template uses the Microsoft.OperationalInsights/workspaces resource provider to create or reference an existing workspace, based on the provided parameters. The output parameters include the workspace ID and name.

## Parameters

| Name                                             | Type     | Required | Description                                                                                                                                    |
| :----------------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`                                       | `string` | Yes      | Specify the location for the workspace.                                                                                                        |
| `prefix`                                         | `string` | No       | Log Analytics Workspace Name Prefix                                                                                                            |
| `name`                                           | `string` | No       | Specify the name of the workspace.                                                                                                             |
| `newOrExisting`                                  | `string` | No       | Create new or use existing workspace                                                                                                           |
| `existingSubscriptionId`                         | `string` | No       | The subscription containing an existing log analytics workspace                                                                                |
| `existingLogAnalyticsWorkspaceResourceGroupName` | `string` | No       | The resource group containing an existing logAnalyticsWorkspaceName                                                                            |
| `sku`                                            | `string` | No       | Specify the pricing tier: PerGB2018 or legacy tiers (Free, Standalone, PerNode, Standard or Premium) which are not available to all customers. |
| `retentionInDays`                                | `int`    | No       | Specify the number of days to retain data.                                                                                                     |
| `resourcePermissions`                            | `bool`   | No       | Specify true to use resource or workspace permissions, or false to require workspace permissions.                                              |

## Outputs

| Name | Type   | Description                       |
| :--- | :----: | :-------------------------------- |
| id   | string | The Log Analytics Workspace ID.   |
| name | string | The Log Analytics Workspace Name. |

## Examples

### Example 1

```bicep
param location string = resourceGroup().location

module logAnalytics 'br/public:operational-insights/log-analytics:0.0.1' = {
  name: 'logAnalytics'
  params: {
    location: location
  }
}

```