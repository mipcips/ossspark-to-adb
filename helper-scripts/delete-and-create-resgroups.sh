#! bin/bash
location='westus'
baseResourceGroupName='rg-wus-hditoadb'
password='Tested2222**'

echo "deleting resource groups"
az group delete -n $baseResourceGroupName -y


echo "creating resource groups"
az group create -l $location -n $baseResourceGroupName

echo "finished refresh of rgs"

echo "deploying..."
az deployment group create  -g $baseResourceGroupName --template-file ./main-hdi.bicep  -n hditoadb --parameters pw=$password


echo "finished !"