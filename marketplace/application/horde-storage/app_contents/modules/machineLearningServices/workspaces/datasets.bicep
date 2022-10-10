param workspaceName_var string
param location string = resourceGroup().location

@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'

resource aml_dataset 'Microsoft.MachineLearningServices/workspaces/datasets@2020-06-01' = if (newOrExisting == 'new') {
  name: '${workspaceName_var}/dataset'
  location: location
  properties: {
    DatasetType: 'file'
    Parameters: {
      Path: {
        DataPath: {
          RelativePath: '/'
          DatastoreName: 'workspaceblobstore'
        }
      }
    }
    registration: {
      Description: 'File datasets'
    }
  }
}
output id string = aml_dataset.id
