@description('The location of the key vault resource.')
param location string = resourceGroup().location

@secure()
@description('A sample kv secret.')
param backgroundColor string

@secure()
@description('A sample kv secret.')
param infoMessage string

@secure()
@description('ACR access token')
param acrToken string

@description('The object ID of the SP to be granted access to the kv.')
param principalId string

@description('The tenant ID of the SP to be granted access to the kv.')
param tenantId string

resource keyVault_resource 'Microsoft.KeyVault/vaults@2021-10-01' = {
  location: location
  name: 'kv-${uniqueString(resourceGroup().id)}'
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
  resource background_color_resource 'secrets@2021-10-01' = {
    name: 'background-color'
    properties: {
      value: backgroundColor
    }
  }
  resource info_message_resource 'secrets@2021-10-01' = {
    name: 'info-message'
    properties: {
      value: infoMessage
    }
  }
  resource acr_token_resource 'secrets@2021-10-01' = {
    name: 'acr-token'
    properties: {
      value: acrToken
    }
  }  
}

output kvName string = keyVault_resource.name
