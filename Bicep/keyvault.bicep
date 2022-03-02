@description('The location of the key vault resource.')
param location string = resourceGroup().location

@secure()
@description('A sample kv secret.')
param secret1 string

@secure()
@description('A sample kv secret.')
param secret2 string

@description('The object ID of the SP to be granted access to the kv.')
param principalId string

@description('The tenant ID of the SP to be granted access to the kv.')
param tenantId string

resource keyVault_resource 'Microsoft.KeyVault/vaults@2021-10-01' = {
  location: location
  name: 'kv1-${uniqueString(subscription().subscriptionId, resourceGroup().id)}'
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: principalId
        tenantId: tenantId
        permissions: {
          secrets: [ 
            'get'
          ]
        }
      }
    ]
  }
  resource secret1_resource 'secrets' = {
    name: 'secret1'
    properties: {
      value: secret1
    }
  }
  resource secret2_resource 'secrets' = {
    name: 'secret2'
    properties: {
      value: secret2
    }
  }
}
