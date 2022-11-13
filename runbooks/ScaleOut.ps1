param
(
    [Parameter(Mandatory=$false)]
    [object] $WebhookData
)

$InitScript = {
    echo "testando1" > /tmp/test1.txt
    echo "testando2" > /tmp/test2.txt
}
Write-Output "Getting information from the webhook payload ..."

if (-Not $WebhookData){
    Write-Error "Webhook variable is empty."
}

if (-Not $WebhookData.RequestBody){
    Write-Error "Error: payload is empty"
}

$JsonString = $WebhookData.RequestBody
$Data = $JsonString | ConvertFrom-Json

$SubscriptionId = $Data.compute.subscriptionId
$ScaleSet       = $Data.compute.vmScaleSetName
$ResourceId     = $Data.compute.resourceId
$ResourceGroup  = $Data.compute.resourceGroupName
$instanceId     = $ResourceId.Split('/')[10]

Write-Output "Connecting in Azure ..."
# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null
# Connect to Azure with system-assigned managed identity
Connect-AzAccount -Identity | Out-Null
$context = Set-AzContext -SubscriptionId $SubscriptionId

Write-Output "Starting init script for vm instance $InstanceId in the $ScaleSet scaleset ..."
$cmd = Invoke-AzVmssVMRunCommand -ResourceGroupName $ResourceGroup -VMScaleSetName $ScaleSet -InstanceId $instanceId -CommandId 'RunShellScript' -ScriptString $InitScript
Write-Output "Status: $($cmd.Status)"