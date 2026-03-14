Import-Module Microsoft.Entra -Force

. "$PSScriptRoot/GetUsersHelper.ps1"
. "$PSScriptRoot/CreateUserHelper.ps1"
. "$PSScriptRoot/CreateBulkUsersHelper.ps1"
. "$PSScriptRoot/SetManagerHelper.ps1"
. "$PSScriptRoot/SearchUser.ps1"

Set-MgGraphOption -DisableLoginByWAM $true


Write-Host "Welcome to the Entra ID User Management Project!" -ForegroundColor Green
Write-Host "This script will help you manage users in Entra ID." -ForegroundColor Blue


try {
    $connection = Get-EntraContext -ErrorAction SilentlyContinue

    if (-not $connection) { #If connection does NOT exist...

        Write-Host "Connecting to Microsoft Entra ID..." -ForegroundColor Cyan

        # Connect with appropriate scopes
        Connect-Entra -Scopes User.ReadWrite.All, Directory.ReadWrite.All, RoleManagement.ReadWrite.Directory

        Get-EntraContext | Select-Object -ExpandProperty Scopes
        
        Write-Host "Only valid domains for this Directory." -ForegroundColor Cyan
        Get-EntraDomain | Select-Object Id, IsVerified, IsDefault

        Write-Host "Connected successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Already connected as: $($connection.Account)" -ForegroundColor Green
    }

    # Step 3: Show the list of users
    Show-UserList
    
    # Step 4: Create a new user (optional)
    Create-NewUser -displayName "Jenny Hall" `
                   -userPrincipalName "JennyHall@CyberSecurityStudent.onmicrosoft.com" `
                   -mailNickname "JennyHallmail" `
                   -password (ConvertTo-SecureString "Pa5sWoRd" -AsPlainText -Force)
    
    Create-BulkUsers -csvFilePath "$PSScriptRoot\bulk_users.csv"

    Set-EmployeeManager -empPrincipalName "xylophone.quasar@CyberSecurityStudent.onmicrosoft.com" `
                        -managerPrincipalName "ignatius.sparkplug@CyberSecurityStudent.onmicrosoft.com"
    

    #Now we do some group operations to show how to manage groups as well
    Write-Host "Retrieving a group..." -ForegroundColor Cyan        
    Set-MgGraphOption -DisableLoginByWAM $true
    Connect-MgGraph -Scopes "Directory.ReadWrite.All"
    


    #At the end of the script, disconnect from Entra ID    
    Disconnect-Entra -ErrorAction SilentlyContinue
}
catch {
    Write-Error "Error: $_"

}
