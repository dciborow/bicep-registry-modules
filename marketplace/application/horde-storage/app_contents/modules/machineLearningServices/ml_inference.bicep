param workspaceName_var string
param amlInferenceClusterName string
param location string
param subnetAKSName string
param subnetAKS string

@description('The number of nodes for the cluster. A minimum of 3 agents are required: https://docs.microsoft.com/en-us/python/api/azureml-core/azureml.core.compute.aks.akscompute.clusterpurpose')
@minValue(3)
@maxValue(50)
param agentCount int = 3
@description('The size of the nodes for AKS Inference Cluster')
param inferenceVmSize string = 'Standard_D3_v2'

@description('Load balancer type to use for the AKS cluster')
@allowed([
  'PublicIp'
  'InternalLoadBalancer'
])
param aksLoadBalancerType string = 'InternalLoadBalancer'
@description('Purpose of the AKS inference cluster')
@allowed([
  'FastProd'
  'DevTest'
])
param clusterPurpose string = 'FastProd'
@description('CIDR to use for AKS cluster\'s service.')
param serviceCidr string = '10.0.0.0/16'
@description('The exposed port for the compute instance.')
param dnsServiceIP string = '10.0.0.10'
@description('CIDR to use for the Docker bridge network address.')
param dockerBridgeCidr string = '172.17.0.1/16'

@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

resource aml_inference 'Microsoft.MachineLearningServices/workspaces/computes@2020-06-01' = if (newOrExisting == 'new') {
  name: '${workspaceName_var}/${amlInferenceClusterName}'
  location: location
  properties: {
    computeType: 'AKS'
    properties: {
      agentCount: agentCount
      agentVMSize: inferenceVmSize
      loadBalancerType: aksLoadBalancerType
      loadBalancerSubnet: subnetAKSName
      clusterPurpose: clusterPurpose
      aksNetworkingConfiguration: {
        serviceCidr: serviceCidr
        dnsServiceIP: dnsServiceIP
        dockerBridgeCidr: dockerBridgeCidr
        subnetId: subnetAKS
      }
    }
  }
}

output id string = aml_inference.id
