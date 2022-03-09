@description('The name of the Managed Cluster resource.')
param aksClusterName string = 'aks101cluster-vmss'

@description('The location of AKS resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('The name of the source key vault.')
param vaultName string = 'managedapps'

@description('The resource group name of the source key vault.')
param vaultResourceGroupName string = 'ContainerRegistry'

@description('The subscription id of the source key vault.')
param vaultSubscriptionId string = ''

resource cua_resource 'Microsoft.Resources/deployments@2021-04-01' = {
  name: 'pid-cd14ef8e-a681-4125-94d8-8240ba4ba74e-partnercenter'
  properties: {
    mode: 'Incremental'
    template: any({
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      'contentVersion': '1.0.0.0'
      'resources': []
    })
  }
}

resource aksCluster_resource 'Microsoft.ContainerService/managedClusters@2020-07-01' = {
  location: location
  name: aksClusterName
  tags: {
    displayname: 'AKS Cluster'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 0
        count: 3
        vmSize: 'Standard_B2s'
        osType: 'Linux'
        storageProfile: 'ManagedDisks'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        config: {
          enableSecretRotation: 'false'
        }
        enabled: true
      }
    }
  }
}

var targetTenantId = aksCluster_resource.identity.tenantId

module nested_mi_resource './mi.bicep' = {
  name: 'kvAddonMi'
  params: {
    aksClusterResourceId: aksCluster_resource.id
  }
}

resource kv 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: vaultName
  scope: resourceGroup(vaultSubscriptionId, vaultResourceGroupName)
}

module nested_keyvault_resource './keyvault.bicep' = {
  name: 'dynamicSecret'
  params: {
    location: location
    backgroundColor: kv.getSecret('background-color')
    infoMessage: kv.getSecret('info-message')
    acrToken: kv.getSecret('acr-token')
    tenantId: targetTenantId
    principalId: nested_mi_resource.outputs.aksKvAccessIdentityObjectId
  }
}

output customerManagedResourceGroupName string = resourceGroup().name
output customerTenantId string = targetTenantId
output customerSubscriptionId string = subscription().subscriptionId
output keyVaultName string = nested_keyvault_resource.outputs.kvName
output keyVaultSecretProviderManagedIdentity string = nested_mi_resource.outputs.aksKvAccessIdentityClientId
output controlPlaneFQDN string = aksCluster_resource.properties.fqdn
