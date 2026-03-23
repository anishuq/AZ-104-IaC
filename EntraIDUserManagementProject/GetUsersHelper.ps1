
function Show-UserList {
<<<<<<< HEAD
Write-Host "Retrieving first 10 users..." -ForegroundColor Cyan
    $users = Get-EntraUser -Top 10
=======
Write-Host "Retrieving first 5 users..." -ForegroundColor Cyan
    $users = Get-EntraUser -Top 5
>>>>>>> b59cdc98cb2682365e681d695c81c0318dff5e75

    $users | Select-Object DisplayName, UserPrincipalName, AccountEnabled 

}