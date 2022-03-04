param aksMiResourceId string

output aksMiResourceId string = aksMiResourceId
output aksMiPrincipalId string = reference(aksMiResourceId, '2020-07-01','Full').properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId
