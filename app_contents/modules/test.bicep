resource clusterUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: 'k8-s5fig5ne422qa'
}

output properties object = clusterUser.properties
