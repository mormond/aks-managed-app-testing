param aksClusterResourceId string

var aksResource = reference(aksClusterResourceId, '2020-07-01','Full')

output aksClusterResourceId string = aksClusterResourceId
output aksKvAccessIdentityClientId string = aksResource.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.clientId
output aksKvAccessIdentityObjectId string = aksResource.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId
