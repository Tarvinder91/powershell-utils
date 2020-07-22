#### This script adds a password to the pfx certificate (if its created without a password)
#############

$NewPwd = ConvertTo-SecureString -String Passw0rd123 -Force -AsPlainText
$mypfx = Get-PfxData -FilePath D:\pre-prod.pfx
Export-PfxCertificate -PFXData $mypfx -FilePath D:\prod.pfx -Password $NewPwd


##################################################
####  Make sure subscription is set ##############

Get-AzureRmSubscription -SubscriptionId "bbe96972-3a14-xxxx-xxxx-2c261afd606a" -TenantId "ea80952e-a476-42d4-xxxx-5457852b0f7e" | Set-AzureRmContext

#######################################################################
####  This is used for binding the certificate to a Web app in Azure ##

$app=Get-AzureRmResource -ResourceId "/subscriptions/xxxx-x-x-x-x-x-x-x/resourcegroups/xxxxxx-rsg/providers/Microsoft.Web/sites/mywebsite-preprod"

###from the list of hostNameSSLStates fetch the ones accoording to need
$app.Properties.hostNameSslStates[0].sslState='SniEnabled'
$app.Properties.hostNameSslStates[0].thumbprint= 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$app.Properties.hostNameSslStates[0].toUpdate = $true
$app|Set-AzureRmResource -Force