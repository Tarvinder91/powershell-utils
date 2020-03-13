#####Copy from Azure Devops to Storage

$URI="https://azcopyvnext.azureedge.net/release20200124/azcopy_windows_amd64_10.3.4.zip"

$AzureStorageAccountLocURL='https://cs106fe09542b60x4784x804.blob.core.windows.net/upload/'

$SASToken='?sv=2019-02-02&ss=bfqt&srt=sco&sp=rwdlacup&se=2020-03-12T18:36:37Z&st=2020-03-12T10:36:37Z&spr=https&sig=fkxULjSW33kAFW4as0mDB5bfnNb9AWihjM0s3fGRs9A%3D'

Invoke-WebRequest -Uri $URI -OutFile "azcopy.zip"

Expand-Archive -LiteralPath azcopy.zip -DestinationPath azcopy

azcopy\azcopy_windows_amd64_10.3.4\azcopy cp   "folder1\" "$AzureStorageAccountLocURL$SASToken" --recursive=true


