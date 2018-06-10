
#################################################################################################################
#                                                                                                               #
# Assesment - Sentia (K. van Dijk)                                                             #
# Version:   1.0                                                                                                #
# Date:      June, 2018                                                                                          #
# By:        Kaylee van Dijk                                                                                    #
#                                                                                                               #
#################################################################################################################   


## Import parameter sheet
$CSV = Import-csv "C:\Users\Kaylee\studious\ParametersScript.txt"
foreach ($item in $CSV)
{
$RGname = $item.RGname
$RGlocation = $item.RGlocation
$storageNamePrefix = $item.storageNamePrefix
$storageSKU = $item.storageSKU
$VNname = $item.VNname
$AddressPrefix = $item.AddressPrefix
$SNname1 = $item.SNname1
$SN1AP = $item.SN1AP
$SNname2 = $item.SNname2
$SN2AP = $item.SN2AP
$SNname3 = $item.SNname3
$SN3AP = $item.SN3AP
}


##Import module for Azure Powershell and connect to account
Import-Module -Name AzureRM
Connect-AzureRmAccount

## Create resource group in West Europe
New-AzureRmResourceGroup -Name $RGname -Location $RGlocation

## Create a Storage Account in the above created Resource Group, using encryption and an unique name, starting with the prefix 'sentia'
New-AzureRmResourceGroupDeployment -ResourceGroupName $RGname -TemplateFile C:\Users\Kaylee\studious\azuredeploystorage.json -storageNamePrefix $storageNamePrefix -storageSKU $storageSKU

## Create Virtual Network in the above created Resource Group with three subnets, using 172.16.0.0/12 as the address prefix
$virtualNetwork = New-AzureRmVirtualNetwork -ResourceGroupName $RGname -Location $RGlocation -Name $VNname -AddressPrefix $AddressPrefix

$subnetConfig1 = Add-AzureRmVirtualNetworkSubnetConfig -Name $SNname1 -AddressPrefix $SN1AP -VirtualNetwork $virtualNetwork
$subnetConfig2 = Add-AzureRmVirtualNetworkSubnetConfig -Name $SNname2 -AddressPrefix $SN2AP -VirtualNetwork $virtualNetwork 
$subnetConfig3 = Add-AzureRmVirtualNetworkSubnetConfig -Name $SNname3 -AddressPrefix $SN3AP -VirtualNetwork $virtualNetwork

$virtualNetwork | Set-AzureRmVirtualNetwork

##Apply the following tags to the resource group: Environment='Test', Company='Sentia'
Set-AzureRmResourceGroup -Name $RGname -Tag @{ Company='Sentia'; Environment="Test" }


##Assign the created policy definition to the subscription and resource group created previously

Register-AzureRmResourceProvider -ProviderNamespace 'Microsoft.PolicyInsights'

$ResourceGroup = Get-AzureRmResourceGroup -Name "$RGname"
$definition = New-AzureRmPolicyDefinition -Name "allowed-resourcetypes" -DisplayName "Allowed resource types" -description "This policy enables you to specify the resource types that your organization can deploy." -Policy 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/built-in-policy/allowed-resourcetypes/azurepolicy.rules.json' -Parameter 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/built-in-policy/allowed-resourcetypes/azurepolicy.parameters.json' -Mode All
New-AzureRmPolicyAssignment -Name "allowedresourcetypesSentia" -PolicyDefinition $definition -Scope $ResourceGroup.ResourceId -PolicyParameter C:\Users\Kaylee\studious\listOfResourceTypesAllowed.json

####################################################END##############################################################################
#Remove-AzureRmResourceGroup -Name $RGname