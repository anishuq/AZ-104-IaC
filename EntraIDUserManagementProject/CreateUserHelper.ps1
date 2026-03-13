function Create-NewUser {
    param (
        [string]$displayName,
        [string]$userPrincipalName,
        [string]$mailNickname,
        [SecureString]$password
    )

    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key]) and Type: $($PSBoundParameters[$key].GetType().Name)"
    } 
    #First we check if this user already exists to avoid duplicates
    
    $existingUser = SearchUser -userPrincipalName $userPrincipalName
    
    if (-not $existingUser) {
        
        try {
            $passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
            $passwordProfile.Password = $password

            
            $userParams = @{
                DisplayName       = $displayName
                UserPrincipalName = $userPrincipalName
                MailNickname      = $mailNickname
                AccountEnabled    = $true
                PasswordProfile   = $passwordProfile
            }
                
                $newUser = New-EntraUser @userParams
                
                Write-Host "User '$displayName' created successfully with UPN '$userPrincipalName'." -ForegroundColor Green
                return $newUser
            }
        catch {
            Write-Host "Error creating user: $_" -ForegroundColor Red
        }
    }
    else {
            Write-Host "User with UPN '$userPrincipalName' already exists: $($existingUser.DisplayName)" -ForegroundColor Yellow
    }
}