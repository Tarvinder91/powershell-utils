## Copy from Azure Devops Container to VM  ##
#############################################
$AdminUser='tarvi'
$AdminPassword="*************6"
winrm quickconfig -q
winrm set winrm/config/client '@{TrustedHosts="*"}'

$ErrorActionPreference = "Stop"    
$AdminSecurePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$AdminCreds = New-Object System.Management.Automation.PSCredential($AdminUser, $AdminSecurePassword)

$Session = New-PSSession -ComputerName $(ServerIP) -Credential $AdminCreds
echo "Copying item..."
Copy-Item -Path ".\folder1\" -Destination "D:\" -ToSession $session -Force -recurse

Remove-PSSession -Session $Session
