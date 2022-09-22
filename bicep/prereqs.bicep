@description('The location of the key vault resource.')
param location string = resourceGroup().location

@description('The name to be given to the key vault resource.')
param kvname string = 'kv-${uniqueString(resourceGroup().id)}'

@description('The object id of the identity to be granted access to the key vault resource.')
param objectId string = 'kv-${uniqueString(resourceGroup().id)}'

@secure()
@description('A sample kv secret.')
param backgroundColor string

@secure()
@description('A sample kv secret.')
param infoMessage string

@secure()
@description('ACR access token')
param acrToken string

var tenantId = subscription().tenantId

resource keyVault_resource 'Microsoft.KeyVault/vaults@2021-10-01' = {
  location: location
  name: kvname
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          secrets: [
            'list'
            'get'
            'set'
          ]
        }
      }
    ]
    enabledForTemplateDeployment: true
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
      contentType: 'base64'
    }
  }
}

resource acr_resource 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: uniqueString(resourceGroup().id)
  location: location
  sku: {
    name: 'Basic'
  }
}

output kvName string = keyVault_resource.name
output acrName string = acr_resource.name
