@description('The name of the Managed Cluster resource.')
param aksClusterName string = 'aks101cluster-vmss'

@description('The location of AKS resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('The name of the source key vault.')
param vaultName string = 'kv-managedapps'

@description('The resource group name of the source key vault.')
param vaultResourceGroupName string = 'managed-app-aks-publisher-source'

@description('The subscription id of the source key vault.')
param vaultSubscriptionId string = ''

// CUA GUID resource required for Marketplace publishing
resource cua_resource 'Microsoft.Resources/deployments@2021-04-01' = {
  name: 'pid-cd14ef8e-a681-4125-94d8-8240ba4ba74e-partnercenter'
  properties: {
    mode: 'Incremental'
    template: any({
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    })
  }
}

// Create an AKS Cluster with system-assigned managed identity
// This will also create two user-assigned managed identities
// One for the KV secrets provider and one for the agent pools
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

// We need to know the customer tenant to associate with the KV
// This allows the KV secrets provider managed identity to access (as it is created in the customer tenant)
// We can get this from the managed identity created by the AKS cluster resource
var targetTenantId = aksCluster_resource.identity.tenantId

// We also need the managed identity of the KV secrets provider
// [a] to create an access policy on the Key Vault (needs objectId)
// [b] to set in the SecretProviderClass in the K8S manifest to pull secrets from Key Vault (needs clientId)
var azureKeyvaultSecretsProviderManagedIdentity = aksCluster_resource.properties.addonProfiles.azureKeyvaultSecretsProvider.identity

// This gets a reference to the existing KV in the publisher tenant
resource kv 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: vaultName
  scope: resourceGroup(vaultSubscriptionId, vaultResourceGroupName)
}

// To get the secrets from the existing KV and set the on the new KV requires a nested template
// We pass the secrets as secure params on the new KV
module nested_keyvault_resource './keyvault.bicep' = {
  name: 'dynamicSecret'
  params: {
    location: location
    backgroundColor: kv.getSecret('background-color')
    infoMessage: kv.getSecret('info-message')
    acrToken: kv.getSecret('acr-token')
    tenantId: targetTenantId
    principalId: azureKeyvaultSecretsProviderManagedIdentity.objectId
  }
}

// Output everything we will need for the K8S manifest deployment + FQDN of cluster
output customerManagedResourceGroupName string = resourceGroup().name
output customerTenantId string = targetTenantId
output customerSubscriptionId string = subscription().subscriptionId
output keyVaultName string = nested_keyvault_resource.outputs.kvName
output keyVaultSecretProviderManagedIdentity string = azureKeyvaultSecretsProviderManagedIdentity.clientId
output controlPlaneFQDN string = aksCluster_resource.properties.fqdn
