#Written by Harry Shelton - June 2025
#Script Name: Basic User Import to 365 Tool
#Script Version: V1.0
#Script import a basic CSV into 365 of users

#Connect to Microsoft Graph with the required scopes
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

#Import CSV file
$users = Import-Csv -Path "C:\Temp\Import_User_Template.csv"
#Headers in CSV are: Username, Display name, First name, Last name

foreach ($user in $users) {
    $passwordProfile = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphPasswordProfile]::new()
    $passwordProfile.Password = "TempP@ssword123!"
    $passwordProfile.ForceChangePasswordNextSignIn = $true

    #Extract user fields
    $userPrincipalName = $user.Username
    $displayName       = $user.'Display name'
    $givenName         = $user.'First name'
    $surname           = $user.'Last name' 

    #Create user
    try {
        New-MgUser -AccountEnabled `
                   -DisplayName $displayName `
                   -UserPrincipalName $userPrincipalName `
                   -MailNickname (($userPrincipalName -split '@')[0]) `
                   -GivenName $givenName `
                   -Surname $surname `
                   -PasswordProfile $passwordProfile

        Write-Host "Created user: $userPrincipalName" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to create user ${userPrincipalName}: $_"
    }
}
