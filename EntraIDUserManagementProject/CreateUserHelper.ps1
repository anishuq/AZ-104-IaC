function Create-NewUser {
    param (
        [string]$displayName,
        [string]$userPrincipalName,
        [string]$mailNickname,
        [SecureString]$password
    )

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

            return $newUser
        }
    catch {
        Write-Host "Error creating user: $_" -ForegroundColor Red
    }
}