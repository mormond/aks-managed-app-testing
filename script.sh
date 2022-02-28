az bicep build --file ./Bicep/azuredeploy.bicep


RG='test-delete'
az deployment group create -g $RG --template-file ./Bicep/azuredeploy.json