param config object = {
  'location': resourceGroup().location
  'resources': {
    'mlWorkspace': 'ml-${uniqueString(resourceGroup().name)}'
  }
  'search': {
    'searchSku': 'storage_optimized_l1'
    'partitionCount': 1
    'replicaCount': 1
  }
}
param subnet object

param computeName string = substring(uniqueString(resourceGroup().id), 0, 13)

@description(' The size of agent VMs. More details can be found here: https://aka.ms/azureml-vm-details.')
param vmSize string = 'STANDARD_D2_v2'

@description('The minimum number of nodes to use on the cluster. If not specified, defaults to 0')
param minNodeCount int = 2

@description(' The maximum number of nodes to use on the cluster. If not specified, defaults to 4.')
param maxNodeCount int = 4

@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

var location  = config.location
var azureMLName = config.resources.mlWorkspace

resource aml_compute 'Microsoft.MachineLearningServices/workspaces/computes@2020-06-01' = if (newOrExisting == 'new') {
  name: '${azureMLName}/${computeName}'
  location: location
  properties: {
    computeType: 'AmlCompute'
    properties: {
      vmSize: vmSize
      vmPriority: 'Dedicated'
      scaleSettings: {
        minNodeCount: minNodeCount
        maxNodeCount: maxNodeCount
      }
      remoteLoginPortPublicAccess: 'Disabled'
      subnet: {
        id: subnet.id
      }
    }
  }
}
output id string = aml_compute.id
