

function New-AzASGCreation {
    param (
        [string]$ASGName,
        [string]$ResourceGroupName,
        [string]$Location,
        [Microsoft.Azure.Commands.Compute.Models.PSVirtualMachine] $VMobj  
    )

    $asgParameters = @{
        Name              = $ASGName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
    }

    $asgObj = New-AzApplicationSecurityGroup @asgParameters

    Write-Host "Created ASG: $ASGName" -ForegroundColor Green

    #Now we add a NIC to the ASG. We will add the NIC of the VM passed in as a parameter to this function.
    if($VMobj -ne $null){
        $nicObj = Get-AzNetworkInterface -ResourceId $VMobj.NetworkProfile.NetworkInterfaces[0].Id -ErrorAction Stop
        
        #Associate the NIC with the ASG
        $nicObj.IPConfigurations[0].ApplicationSecurityGroups = $asgObj
        $nicObj = Set-AzNetworkInterface -NetworkInterface $nicObj

        Write-Host "Associated NIC: $($nicObj.Name) with ASG: $ASGName" -ForegroundColor Green
    }

    return $asgObj
}