# Public IP Address

This Bicep template deploys a public IP address resource in Azure and can associate a DNS zone with the IP address.

## Description

This Bicep template can be used to deploy a public IP address resource in Azure.
The public IP address resource provides a static, publicly routable IP address that can be used to communicate with resources deployed in Azure. The template includes options for creating a new or using an existing public IP resource, specifying a DNS zone, and setting the allocation method and SKU for the public IP address.

## Parameters

| Name                       | Type     | Required | Description                                                                                                                                                                                                         |
| :------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `location`                 | `string` | Yes      | Deployment Location                                                                                                                                                                                                 |
| `resourceGroupName`        | `string` | No       | Resource Group Name                                                                                                                                                                                                 |
| `prefix`                   | `string` | No       | Public IP Resource Prefix                                                                                                                                                                                           |
| `name`                     | `string` | No       | PublicIP Resource Name                                                                                                                                                                                              |
| `useDnsZone`               | `bool`   | No       | If this is true, dnsZoneName, etc. should be specified                                                                                                                                                              |
| `dnsZoneName`              | `string` | No       | Specifies the name of the DNS zone to be used for the DNS record.                                                                                                                                                   |
| `dnsZoneResourceGroupName` | `string` | No       | Specifies the name of the resource group containing the DNS zone.                                                                                                                                                   |
| `dnsRecordNameSuffix`      | `string` | No       | Specifies the suffix to be used for the DNS record name. For example, if this parameter is set to "frontend", and the DNS zone name is "example.com", the resulting DNS record name will be "frontend.example.com". |
| `newOrExisting`            | `string` | No       | Create new or use existing resource selection. new/existing                                                                                                                                                         |
| `publicIpSku`              | `object` | No       | Specifies the SKU (stock-keeping unit) of the public IP address.                                                                                                                                                    |
| `publicIpAllocationMethod` | `string` | No       | Specifies the allocation method of the public IP address. Possible values are Static or Dynamic.                                                                                                                    |
| `publicIpDns`              | `string` | No       | Specifies the domain name label for the public IP address.                                                                                                                                                          |
| `existingSubscriptionId`   | `string` | No       | The subscription containing an existing dns zone                                                                                                                                                                    |

## Outputs

| Name      | Type   | Description       |
| :-------- | :----: | :---------------- |
| id        | string | Public IP Id      |
| name      | string | Public IP Name    |
| ipAddress | string | Public IP Address |

## Examples

### Example 1

```bicep
param location string = resourceGroup().location

module publicIP 'br/public:network/public-ip-addresses:0.0.1' = {
  name: 'publicIpAddressess'
  params: {
    location: location
  }
}
```