<#
We are simply to create a Resource Group and add some tags to it. 
We will also create a virtual network and a VM, and add some tags to them as well.
This is a very simple script, but it will help you understand how to use tags in Azure.
#>

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

$rgObj = New-AzResourceGroup -Name "az104tags-rg" -Location "EastUS"

$tagsRG = @{
    "Environment" = "Production"
    "Department" = "IT"
    "Project" = "Azure104"
}

$rgObj | Set-AzResourceGroup -Tag $tagsRG

$Vmname = "vmtags-01"
$Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"


$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe-45WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)


$vmObj = New-AzVM -ResourceGroupName $rgObj.ResourceGroupName `
         -Name $Vmname `
         -Location $rgObj.Location `
         -Size "Standard_B1s" `
         -VirtualNetworkName "vnet-tags-01" `
         -SubnetName "subnet-tags-01" `
         -PublicIpAddressName "pip-tags-01" `
         -OpenPorts 22 `
         -Image $Image `
         -Credential $vmcred

$tagsVM = @{
    "Environment" = "Development"
    "Department" = "Finance"
    "Purpose" = "Demo"
}

New-AzTag -ResourceId $vmObj.Id -Tag $tagsVM

New-AzResourceLock -LockName "DeleteLockRG" -ResourceGroupName $rgObj.ResourceGroupName `
                    -LockLevel CanNotDelete 
