param config object = {
  'location': resourceGroup().location
  'tags': {
    'aia-industry': 'industry'
    'aia-solution': 'solution'
    'aia-version': '0.0'
  }
  'enable': {
    'vNET': false
  }
  'resources': {
    'registries': 'acr${uniqueString(resourceGroup().id)}'
  }
}

param item object
param metricThresholdToScaleOut int
param metricThresholdToScaleIn int
param itemUriID string

resource autoscalesettings 'Microsoft.Insights/autoscalesettings@2015-04-01' = {
  name: item.uriName
  location: config.location
  properties: {
    targetResourceUri: itemUriID
    enabled: true
    profiles: [
      {
        name: 'Autoscale by percentage based on memory usage'
        capacity: {
          minimum: '1'
          maximum: '${(startsWith(item.sku, 'S') ? 10 : 30)}'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'MemoryPercentage'
              metricResourceUri: itemUriID
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: metricThresholdToScaleOut
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '2'
              cooldown: 'PT30M'
            }
          }
          {
            metricTrigger: {
              metricName: 'MemoryPercentage'
              metricResourceUri: itemUriID
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: metricThresholdToScaleIn
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT30M'
            }
          }
        ]
      }
    ]
  }
}
output id string = autoscalesettings.id
