Write-Host "Service Endpoint Helper Loaded!"

#Create an Azure Service that suports Service Endpoints.

function testAccess{Write-Host "test function called!"}

function New-AzSqlServerWithServiceEndpoint{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$SqlServerName,
        [System.Management.Automation.PSCredential] $Credential, 
        [string]$vnetName
    )

    #print all the params
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    } 

    #Create the SQL Server
    $SqlServerParameters = @{
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        ServerName        = $SqlServerName
        SqlAdministratorCredentials = $Credential
        ErrorAction      = "Stop"
    }

    $sqlServerObj = New-AzSqlServer @SqlServerParameters

    #Now we create a DB in the SQL Server
    $DatabaseParameters = @{
        ResourceGroupName = $ResourceGroupName
        ServerName        = $SqlServerName
        DatabaseName      = "DemoDB"
        ErrorAction      = "Stop"
    }

    $sqlDatabaseObj = New-AzSqlDatabase @DatabaseParameters

    <#
    The following does NOT work, i.e. adding rule to the Server's FW.
    As its beyond the scope of this lab, we will do it the manual way via portal.
    #>
    #Get the Subnet
    <#$vnetObej = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $vnetName
    $subnetObj = $vnetObej.Subnets | Where-Object { $PSItem.Name -eq "SQL_subnet" }

    

    # 3. Explicitly add the Service Endpoint to the object
    $subnetObj.ServiceEndpoints.Add(@{service="Microsoft.Sql"})

    # 4. SAVE the change back to Azure (Crucial step!)
    $vnetObej | Set-AzVirtualNetwork

    New-AzSqlServerVirtualNetworkRule -ResourceGroupName $ResourceGroupName `
    -ServerName $SqlServerName -VirtualNetworkRuleName "AllowTrafficFrom-$($subnetObj.Name)" `
    -VirtualNetworkSubnetId $subnetObj.Id  
    #>


    
}