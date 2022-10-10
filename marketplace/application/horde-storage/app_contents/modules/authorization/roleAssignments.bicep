param identity object
param crossTenant bool = false

var identityName = 'scratch'
var roleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var roleAssignmentName = guid(identityName, roleDefinitionId)

resource identityRoleAssignDeployment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
    delegatedManagedIdentityResourceId: (bool(crossTenant) ? identity.id : json('null'))
  }
}
output id string = identityRoleAssignDeployment.id
