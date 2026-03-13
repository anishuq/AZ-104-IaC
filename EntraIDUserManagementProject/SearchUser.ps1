

function SearchUser {
    param (
        [string]$userPrincipalName
    )
    
    $existingUser = Get-EntraUser -Filter "userPrincipalName eq '$userPrincipalName'" -ErrorAction SilentlyContinue

    return $existingUser
}