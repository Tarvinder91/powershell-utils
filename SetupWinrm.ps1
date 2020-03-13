#Setup Winrm:
#-----------


$fileUri = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/501dc7d24537e820df7c80bce51aba9674233b2b/201-vm-winrm-windows/ConfigureWinRM.ps1'
$certUri = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/501dc7d24537e820df7c80bce51aba9674233b2b/201-vm-winrm-windows/makecert.exe'


Invoke-WebRequest -Uri $fileUri -OutFile ConfigureWinRM.ps1
Invoke-WebRequest -Uri $certUri -OutFile makecert.exe

powershell -ExecutionPolicy Unrestricted -file ConfigureWinRM.ps1 52.189.193.105  # we can pass computer name here.




