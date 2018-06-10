First fill in the required parameters in ParametersScript.txt
# Default storageNamePrefix = "Sentia" . Maximum of 11 characters.
# Default storageSKU = "Standard_LRS" (type of redundancy). It is limited to values that are valid for a storage account ("Standard_LRS","Standard_GRS","Standard_RAGRS")

Second run the SentiaAssesmentScript.ps1 file.
The script creates:
- Resource Group
- Storage Account
- Virtual Network
- Tags
- Policy.  
This sript uses the files:
- ParametersScript.txt
- azuredeplostorage.json
- listOfResourceTypesAllowed.json
