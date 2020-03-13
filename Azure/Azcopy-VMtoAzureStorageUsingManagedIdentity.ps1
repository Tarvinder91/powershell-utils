#https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/tutorial-vm-windows-access-storage


                                #########  AZCOPY  #########
#Prerequisites:
#1) Download AZCOPY
$URI="https://azcopyvnext.azureedge.net/release20200124/azcopy_windows_amd64_10.3.4.zip"

Invoke-WebRequest -Uri $URI -OutFile "azcopy.zip"
Expand-Archive -LiteralPath azcopy.zip -DestinationPath azcopy

# 2) Create VM Identity
# Give access to the VM (identity) on the storage account.
    ## Go to storage- IAM - -> Select role 'Storage Blob Data Contributor' -> 
    ## ->Assign access to 'Virtual machine' -> Select the desired VM -> SAVE 

## If we add the VM to resource group IAM with same role
    ## -> we can give access at RG level that will give access to all storage accoutns in this RG.

#STEPS:
# 3) Login to VM and assume the identity:
azcopy login --identity 
#./azcopy login  --identity           [linux]

# If you are a user credentials 
# azcopy login --tenant-id '<tenant-id>’

#If using user-assigned managed identity 
# azcopy login --identity --identity-client-id "383bsdf-b533-48a1-8a67-9be8954edb5a"

# 4) COPY
$AzureStorageAccountLocURL='https://cs106fe09542b60x4784x804.blob.core.windows.net/study/'

azcopy cp "c:\temp\ThirdPartyNotice.txt" "$AzureStorageAccountLocURL" --recursive=true




