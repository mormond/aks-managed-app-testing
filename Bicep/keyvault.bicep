@description('The location of the key vault resource.')
param location string = resourceGroup().location

@secure()
param secret1 string

@secure()
param secret2 string

param principalId string

resource keyVault_resource 'Microsoft.KeyVault/vaults@2021-10-01' = {
  location: location
  name: 'kv1-${uniqueString(subscription().subscriptionId, resourceGroup().id)}'
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: [
      {
        objectId: principalId // '61248cef-973e-4471-92fb-fe3653b1d804' // This is the objectId of our managed identity
        tenantId: subscription().tenantId
        permissions: {
          secrets: [ 
            'all'
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