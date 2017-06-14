az login
az account set --subscription <SubscriptionId>
az group create --name dpubuntudocker --location westeurope
az group deployment create --resource-group dpubuntudocker --template-file ubuntudocker.template.json --parameters @ubuntudocker.parameters.json
az group delete --name dpubuntudocker --yes