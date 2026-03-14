
function Set-EmployeeManager {
    param (
        [string]$empPrincipalName,
        [string]$managerPrincipalName
    )
    
       foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key]) and Type: $($PSBoundParameters[$key].GetType().Name)"
    }

    $employee = SearchUser -userPrincipalName $empPrincipalName
    $manager = SearchUser -userPrincipalName $managerPrincipalName


    if($employee -and $manager) {
        try {
            Set-EntraUserManager -UserId $empPrincipalName -RefObjectId $manager.ObjectId
            Write-Host "Manager for '$($employee.DisplayName)' set to '$($manager.DisplayName)' successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Error setting manager: $_" -ForegroundColor Red
        }
    }
    else {
        if(-not $employee) {
            Write-Host "Employee with UPN '$empPrincipalName' not found." -ForegroundColor Yellow
        }
        if(-not $manager) {
            Write-Host "Manager with UPN '$managerPrincipalName' not found." -ForegroundColor Yellow
        }
    }
}