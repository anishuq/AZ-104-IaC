. "$PSScriptRoot/CreateUserHelper.ps1"

function Create-BulkUsers{
    param (
        [string]$csvFilePath
    )
    
    Import-Csv -Path $csvFilePath | ForEach-Object {
      
    write-host "Creating user: $($_.displayname) with UPN: $($_.upn)" -ForegroundColor Cyan
    Create-NewUser -displayName $_.displayname `
                       -userPrincipalName $_.upn `
                       -mailNickname $_.mailnickname `
                       -password (ConvertTo-SecureString $_.password -AsPlainText -Force)
    }   
}