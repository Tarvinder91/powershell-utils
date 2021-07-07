# This script runs some processes on remote computers using Winrm
# Prerequisite:
# servers.txt and svc_accounts.txt must exits in the folder where the script is run.

$file = Get-Content -Path ./servers.txt
$output_file='.\output.csv'

New-Item $output_file -ItemType File -Force
Set-Content $output_file 'Server,Test,Result'

ForEach ($line in $file) {
$result=test-Connection $line -Quiet -count 1
Add-Content $output_file "$line,PINGSTATUS,$result"
}

#################################TEST2 TCP ##########################

ForEach ($line in $file)
{
foreach ($port in @(3389,135,445))
 {
$result =  Test-NetConnection -ComputerName $line -Port $port   | Select -ExpandProperty tcptestsucceeded 

if($result)
  { Add-Content $output_file "$line,TCPCOONNECT$port,OK" } 
else 
  {Add-Content $output_file "$line,TCPCOONNECT$port,NOTOK" }


}
}


###################################################
##• Discovery Id access on server (whether 3 service accounts are added in "administrators" group on problematic servers)
###################################################
#Checking Service accounts
$file = Get-Content -Path ./servers.txt
$svc_acc = Get-Content -Path ./svc_accounts.txt


#$AdminUser='Administrator'
#$AdminPassword="Hello@123"

#$ErrorActionPreference = "Stop"
#$AdminSecurePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
#$AdminCreds = New-Object System.Management.Automation.PSCredential($AdminUser, $AdminSecurePassword)


ForEach ($line in $file)
{
ForEach ($acc in $svc_acc)
{
##$acc_result=Invoke-Command -ComputerName $line -Credential $AdminCreds  -ScriptBlock { Get-LocalGroupMember -Name 'Administrators' | where {$_.Name -match $Using:acc} }
$acc_result=Invoke-Command -ComputerName $line  -ScriptBlock { Get-LocalGroupMember -Name 'Administrators' | where {$_.Name -match $Using:acc} }

if ($acc_result){ Add-Content $output_file "$line,$acc,OK" } 
else {Add-Content $output_file "$line,$acc,NOTOK" }
}
}


##########################################################################################
## FIREWALL TEST

ForEach ($line in $file)
{

#echo $acc
#$Firewall_status=Invoke-Command -ComputerName $line -Credential $AdminCreds  -ScriptBlock {Get-NetFirewallProfile | Select -property Name,Enabled } 
$Firewall_status=Invoke-Command -ComputerName $line  -ScriptBlock {Get-NetFirewallProfile | Select -property Name,Enabled } 

$domain_f_status=$Firewall_status| where {$_.Name -match 'Domain'} | select  -ExpandProperty Enabled 
$public_f_status=$Firewall_status| where {$_.Name -match 'Public'} | select  -ExpandProperty Enabled 
$private_f_status=$Firewall_status| where {$_.Name -match 'Private'} | select  -ExpandProperty Enabled 

if ($domain_f_status | Select -expandproperty value)
    { Add-Content $output_file "$line,DOMAINFIREWALL,OK" } 
else {Add-Content $output_file "$line,DOMAINFIREWALL,NOTOK" }

if ($public_f_status | Select -expandproperty value)
    { Add-Content $output_file "$line,PUBLICFIREWALL,OK" } 
else {Add-Content $output_file "$line,PUBLICFIREWALL,NOTOK" }


if ($private_f_status | Select -expandproperty value)
    { Add-Content $output_file "$line,PRIVATEFIREWALL,OK" } 
else {Add-Content $output_file "$line,PRIVATEFIREWALL,NOTOK" }


}

##NETSTAT TEST FOR PORT 135 
############################

ForEach ($line in $file)
{
##$netstat_status135=Invoke-Command -ComputerName $line -Credential $AdminCreds  -ScriptBlock { netstat -ano | find '"135"'} 
##$netstat_status445=Invoke-Command -ComputerName $line -Credential $AdminCreds  -ScriptBlock { netstat -ano | find '"445"'} 

$netstat_status135=Invoke-Command -ComputerName $line -ScriptBlock { netstat -ano | find '"135"'} 
$netstat_status445=Invoke-Command -ComputerName $line -ScriptBlock { netstat -ano | find '"445"'} 


if($netstat_status135)
 {
   if ($netstat_status135[0] -like '*LISTENING*')
       { Add-Content $output_file "$line,NETSTATPORT135,OK" } 
  }
else 
  { Add-Content $output_file "$line,NETSTATPORT135,NOTOK" }

if($netstat_status445)
 {
   if ($netstat_status445[0] -like '*LISTENING*')
       { Add-Content $output_file "$line,NETSTATPORT445,OK" } 
  }
else 
  { Add-Content $output_file "$line,NETSTATPORT445,NOTOK" }

}

###############################################################
# WMI QUERY

ForEach ($line in $file)
{
#$wmi_result=Invoke-Command -ComputerName $line -Credential $AdminCreds  -ScriptBlock { gwmi win32_computerSystem}

$wmi_result=Invoke-Command -ComputerName $line -ScriptBlock { gwmi win32_computerSystem}
if ($wmi_result)
    { 
    $WMIDomain= $wmi_result | Select -ExpandProperty  Domain
    $WMIManufacturer= $wmi_result | Select -ExpandProperty  Manufacturer
    $WMIModel= $wmi_result | Select -ExpandProperty  Model
    $WMIName= $wmi_result | Select -ExpandProperty  Name
    $WMIPrimaryOwnerName = $wmi_result | Select -ExpandProperty  PrimaryOwnerName
    $WMITotalPhysicalMemory= $wmi_result | Select -ExpandProperty  TotalPhysicalMemory

    Add-Content $output_file "$line,WMIDOMAIN,$WMIDomain"
    Add-Content $output_file "$line,WMIManufacturer,$WMIManufacturer"
    Add-Content $output_file "$line,WMIModel,$WMIModel"
    Add-Content $output_file "$line,WMIName,$WMIName"
    Add-Content $output_file "$line,WMIPrimaryOwnerName,$WMIPrimaryOwnerName"
    Add-Content $output_file "$line,WMITotalPhysicalMemory,$WMITotalPhysicalMemory"
    }
else
{
    Add-Content $output_file "$line,WMIDOMAIN,OK" 
    Add-Content $output_file "$line,WMIQUERY,NOTOK"
    }
}

###############################################################
# NETSTAT

ForEach ($line in $file)
{
#$UDPrange_result=Invoke-Command -ComputerName $line -Credential $AdminCreds  -ScriptBlock { Get-NetUDPSetting  }
$UDPrange_result=Invoke-Command -ComputerName $line -ScriptBlock { Get-NetUDPSetting  }

$UDPStartPort= $UDPrange_result | Select -ExpandProperty  DynamicPortRangeStartPort
$UDPPortRange= $UDPrange_result | Select -ExpandProperty  DynamicPortRangeNumberOfPorts
if ($UDPrange_result)
    { Add-Content $output_file "$line,UDPDYNAMICSTARTPORT,$UDPStartPort"
    Add-Content $output_file "$line,UDPDYNAMICPORTRANGE,$UDPPortRange"}

else 
    {Add-Content $output_file "$line,UDPDYNAMICSTARTPORT,NOTOK"
    Add-Content $output_file "$line,UDPDYNAMICPORTRANGE,NOTOK"}

}





