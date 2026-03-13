
function Show-UserList {
Write-Host "Retrieving first 5 users..." -ForegroundColor Cyan
    $users = Get-EntraUser -Top 5

    $users | Select-Object DisplayName, UserPrincipalName, AccountEnabled 

}