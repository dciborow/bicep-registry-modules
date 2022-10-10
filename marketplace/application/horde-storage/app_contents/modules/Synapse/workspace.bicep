//  -------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  -------------------------------------------------------------
// PLAYFAB CHURN PREDICTION

// Default Parameters
  param name                          string = uniqueString(resourceGroup().name)
  param location                      string = resourceGroup().location
  param tags                          object = {}

// Parameters
  param azureADOnlyAuthentication     bool = true
  param initialWorkspaceAdminObjectId string

// Variables
  var identity                         = {
    type: 'None'
    userAssignedIdentities: {}
  }

  var cspWorkspaceAdminProperties      = {
    initialWorkspaceAdminObjectId: initialWorkspaceAdminObjectId
  }

  var defaultDataLakeStorage           = {
    accountUrl: ''
    createManagedPrivateEndpoint: true
    filesystem: ''
    resourceId: ''
  }

  var encryption                       = {
    cmk: {
      kekIdentity: {
        userAssignedIdentity: ''
        useSystemAssignedIdentity: ''
      }
      key: {
        keyVaultUrl: ''
        name: ''
      }
    }
  }

  var managedVirtualNetworkSettings    = {
    allowedAadTenantIdsForLinking: [
      ''
    ]
    linkedAccessCheckOnTargetResource: true
    preventDataExfiltration: true
  }

  var privateEndpointConnections       = [
    {
      properties: {
        privateEndpoint: {}
        privateLinkServiceConnectionState: {
          description: 'string'
          status: 'string'
        }
      }
    }
  ]

  var purviewConfiguration             = {
    purviewResourceId: 'string'
  }

  var virtualNetworkProfile            = {
    computeSubnetId: ''
  }

  var workspaceRepositoryConfiguration = {
    accountName: ''
    collaborationBranch: ''
    hostName: ''
    lastCommitId: ''
    projectName: ''
    repositoryName: ''
    rootFolder: ''
    tenantId: ''
    type: ''
  }

  var properties                       = {
    azureADOnlyAuthentication       : azureADOnlyAuthentication
    connectivityEndpoints           : {}
    cspWorkspaceAdminProperties     : cspWorkspaceAdminProperties
    defaultDataLakeStorage          : defaultDataLakeStorage
    encryption                      : encryption
    managedResourceGroupName        : 'string'
    managedVirtualNetwork           : 'string'
    managedVirtualNetworkSettings   : managedVirtualNetworkSettings
    privateEndpointConnections      : privateEndpointConnections
    publicNetworkAccess             : 'string'
    purviewConfiguration            : purviewConfiguration
    sqlAdministratorLogin           : 'string'
    sqlAdministratorLoginPassword   : 'string'
    virtualNetworkProfile           : virtualNetworkProfile
    workspaceRepositoryConfiguration: workspaceRepositoryConfiguration
  }

// Resources
    resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
      name      : name
      location  : location
      tags      : tags
      identity  : identity
      properties: properties
    }

// Output
    output synapseId string = synapse.id
