#Written by Harry Shelton - June 2025
#Script Name: Bulk Password Reset Tool
#Script Version: V1.0
#Script will reset all users under a certain domain as the primary email.

Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.Read.All"

#User Collection - Edit the domain.co.uk to match yours
$targetUsers = Get-MgUser -Filter "endsWith(userPrincipalName,'@domain.co.uk')" `
                          -ConsistencyLevel eventual `
                          -CountVariable count `
                          -All

$results = @()

foreach ($user in $targetUsers) {
    #Character pools for password
    $upper = 65..90 | ForEach-Object {[char]$_}
    $lower = 97..122 | ForEach-Object {[char]$_}
    $digits = 48..57 | ForEach-Object {[char]$_}
    $special = @('!', '@', '#', '$', '%', '^', '&', '*')

    #Ensure at least one special char
    $randomChars = @()
    $randomChars += $special | Get-Random -Count 1

    #Fill remaining 10 chars from all pools
    $allChars = $upper + $lower + $digits + $special
    $randomChars += $allChars | Get-Random -Count 10

    #Shuffle characters randomly
    $randomPasswordPart = ($randomChars | Get-Random -Count $randomChars.Count) -join ''
    $newPassword = "$randomPasswordPart"

    $passwordProfile = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphPasswordProfile]::new()
    $passwordProfile.Password = $newPassword
    $passwordProfile.ForceChangePasswordNextSignIn = $true

    try {
        #Reset user's password against the passwordProfile function
        Update-MgUser -UserId $user.Id -PasswordProfile $passwordProfile

        Write-Host "✅ Password reset for $($user.UserPrincipalName): $newPassword" -ForegroundColor Green

        $results += [pscustomobject]@{
            UserPrincipalName = $user.UserPrincipalName
            NewPassword       = $newPassword
            Status            = "Success"
        }
    }
    catch {
        Write-Warning "❌ Failed to reset password for $($user.UserPrincipalName): $_"
        $results += [pscustomobject]@{
            UserPrincipalName = $user.UserPrincipalName
            NewPassword       = ""
            Status            = "Failed: $_"
        }
    }
}

#Export results to CSV
$results | Export-Csv -Path "C:\Temp\PasswordResetLog.csv" -NoTypeInformation

Write-Host "Password reset operation completed. Log exported to C:\Temp\PasswordResetLog.csv"
