@description('The name of the Managed Cluster resource.')
param aksClusterName string = 'aks101cluster-vmss'

@description('The location of AKS resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

// @description('The number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
// @minValue(1)
// @maxValue(5)
// param agentCount int = 1

// @description('The size of the Virtual Machine.')
// param agentVMSize string = 'Standard_B2s'

// @description('The type of operating system.')
// @allowed([
//   'Linux'
//   'Windows'
// ])
// param osType string = 'Linux'

resource aksClusterName_resource 'Microsoft.ContainerService/managedClusters@2020-07-01' = {
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
        count: 1
        vmSize: 'Standard_B2s'
        osType: 'Linux'
        storageProfile: 'ManagedDisks'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
  }
}

output controlPlaneFQDN string = aksClusterName_resource.properties.fqdn
