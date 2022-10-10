param virtualNetworkId string

module VirtualNetworklink_3bdb4978_9caf_499e_bed5_d4a4f324b05f './virtualNetworkLinks.bicep' = {
  name: 'VirtualNetworklink-3bdb4978-9caf-499e-bed5-d4a4f324b05f'
  scope: resourceGroup()
  params: {
    virtualNetworkId: virtualNetworkId
  }
}
