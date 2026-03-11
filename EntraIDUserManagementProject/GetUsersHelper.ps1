
function Show-UserList {
Write-Host "Retrieving first 10 users..." -ForegroundColor Cyan
    $users = Get-EntraUser -Top 10

    $users | Select-Object DisplayName, UserPrincipalName, AccountEnabled 

}