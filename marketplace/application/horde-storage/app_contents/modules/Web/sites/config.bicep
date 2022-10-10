resource containerRegistryName_Microsoft_Authorization_containerRegistryName 'Microsoft.ContainerRegistry/registries/providers/roleAssignments@2020-04-01-preview' = {
  tags: tags
  name: '${containerRegistryName}/Microsoft.Authorization/${guid(containerRegistryName)}'
  properties: {
    roleDefinitionId: acrPullRole
    principalId: servicePrincipalAppId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    containerRegistryName_resource
  ]
}
