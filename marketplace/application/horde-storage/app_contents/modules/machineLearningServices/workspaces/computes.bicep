param config object = {
  'location': resourceGroup().location
  'tags': {
    'aia-industry': 'industry'
    'aia-solution': 'solution'
    'aia-version': '0.0'
  }
  'uniqueKey': uniqueString(resourceGroup().id)
  'enable': {
    'vNET': false
  }
}

@minValue(1)
@maxValue(50)
param agentCount int = 6

param agentVMSize string = 'Standard_DS2_v2'

@allowed([
  'FastProd'
  'DevTest'
])
param clusterPurpose string = 'FastProd'


param existingVirtualNetworkResourceGroup string = ''

param serviceCidr string = '192.168.0.0/16'
param dnsServiceIP string = '192.168.0.10'
param dockerBridgeCidr string = '172.17.0.1/16'

var existingVirtualNetworkName = config.resoureces.vNetName
var amlInferenceClusterName = config.resoureces.aksName
var existingAmlWorkspaceName = config.resoureces.mlWorkspace
var existingSubnetName = config.resoureces.aksSubnet

var aksNetworkingConfiguration = config.enable.AKSVNET && config.enable.databricks ? {
  serviceCidr: serviceCidr
  dnsServiceIP: dnsServiceIP
  dockerBridgeCidr: dockerBridgeCidr
  subnetId: resourceId(existingVirtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', existingVirtualNetworkName, existingSubnetName)
} : {}

var loadBalancerType = config.enable.AKSVNET && config.enable.databricks ? 'InternalLoadBalancer' : 'PublicIp'

resource workspace 'Microsoft.MachineLearningServices/workspaces/computes@2020-06-01' = {
  tags: config.tags
  name: '${existingAmlWorkspaceName}/${amlInferenceClusterName}'
  location: config.location
  properties: {
    computeType: 'AKS'
    properties: {
      agentCount: agentCount
      agentVMSize: agentVMSize
      loadBalancerType: loadBalancerType
      loadBalancerSubnet: config.enable.AKSVNET && config.enable.databricks ? existingSubnetName : ''
      clusterPurpose: clusterPurpose
      aksNetworkingConfiguration: aksNetworkingConfiguration
    }
  }
}

output id string = workspace.id
