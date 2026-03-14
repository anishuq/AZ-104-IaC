Import-Module Microsoft.Entra -Force

. "$PSScriptRoot/GetUsersHelper.ps1"
. "$PSScriptRoot/CreateUserHelper.ps1"


Set-MgGraphOption -DisableLoginByWAM $true


Write-Host "Welcome to the Entra ID User Management Project!" -ForegroundColor Green
Write-Host "This script will help you manage users in Entra ID." -ForegroundColor Blue


try {
    $connection = Get-EntraContext -ErrorAction SilentlyContinue

    if (-not $connection) { #If connection does NOT exist...

        Write-Host "Connecting to Microsoft Entra ID..." -ForegroundColor Cyan

        # Connect with appropriate scopes
        Connect-Entra -Scopes User.ReadWrite.All, Directory.ReadWrite.All, RoleManagement.ReadWrite.Directory

        Get-EntraContext | Select-Object -ExpandProperty Scopes | Sort-Object

        Write-Host "Connected successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Already connected as: $($connection.Account)" -ForegroundColor Green
    }

    # Step 3: Show the list of users
    Show-UserList
    
    # Step 4: Create a new user (optional)
    <#Create-NewUser -displayName "James Hall" `
                   -userPrincipalName "JamesHall@CyberSecurityStudent.onmicrosoft.com" `
                   -mailNickname "JamesHallmail" `
                   -password (ConvertTo-SecureString "Pa5sWoRd" -AsPlainText -Force)
    #>
    #At the end of the script, disconnect from Entra ID    
    Disconnect-Entra -ErrorAction SilentlyContinue
}
catch {
    Write-Error "Error: $_"

}
