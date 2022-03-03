# Useful snippets of script

# Generate ARM templace from Bicep file
az bicep build --file ./Bicep/mainTemplate.bicep

# Resource group deployment of ARM template
RG="test-delete"
if [[ $(az group exists --resource-group "$RG") == 'false' ]]; then
    az group create --location "westeurope" --resource-group "$RG"
    az deployment group create --resource-group "$RG" --template-file "./Bicep/mainTemplate.json"
else
    echo "Resource group exists"
fi