az bicep build --file ./Bicep/azuredeploy.bicep


RG='test-delete'

az group create -l westeurope -g $RG

az deployment group create -g $RG --template-file ./Bicep/azuredeploy.json