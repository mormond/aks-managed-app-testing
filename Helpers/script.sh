# Useful snippets of script

# Generate ARM templace from Bicep file
az bicep build --file ./Bicep/azuredeploy.bicep

# Resource group deployment of ARM template
RG="test-delete"
az group create --location "westeurope" --group "$RG"
az deployment group create --group "$RG" --template-file "./Bicep/azuredeploy.json"