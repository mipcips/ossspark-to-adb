#! bin/bash
location='westus'
baseResourceGroupName='rg-wus-hditoadb'
mngResourceGroupName='rg-wus-adbmng-hditoadb'


echo "deleting resource groups"
az group delete -n $baseResourceGroupName -y
az group delete -n $mngResourceGroupName -y

echo "creating resource groups"
az group create -l $location -n $baseResourceGroupName
az group create -l $location -n $mngResourceGroupName

echo "finished refresh of rgs"

echo "deploying..."
az deployment group create  -g $baseResourceGroupName --template-file ./main-hdi.bicep  -n hditoadb --parameters pw=Tested2222** adbMngResourceGroupName=$mngResourceGroupName


echo "finished !"