# Useful snippets of script

# Generate ARM templace from Bicep file
az bicep build --file ./Bicep/mainTemplate.bicep

# Resource group deployment of ARM template
SUB_ID=""
RG=""

if [[ "$RG" == "" ]]; then 
    echo "Please supply a resource group."
fi

if [[ "$SUB_ID" == "" ]]; then 
    echo "Please supply a subscription ID."
fi

if [[ $(az group exists --resource-group "$RG") == 'false' ]]; then
    az group create --location "westeurope" --resource-group "$RG"
    az deployment group create --resource-group "$RG" --template-file "./Bicep/mainTemplate.json" --params vaultSubscriptionId="$SUB_ID"
else
    echo "Resource group exists"
fi