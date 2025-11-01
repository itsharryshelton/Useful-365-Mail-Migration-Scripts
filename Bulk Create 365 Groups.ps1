#Written by Harry Shelton - June 2025
#Script Name: Bulk Group Creation Tool
#Script Version: V1.0

#Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All", "User.Read.All", "Directory.ReadWrite.All"

#Load CSV
$groups = Import-Csv -Path "C:\temp\365Groups.csv"
#Headers are displayName, mailNickname

#Set owner
$ownerEmail = "user@domain.com"
$owner = Get-MgUser -UserId $ownerEmail

foreach ($group in $groups) {
    $displayName = $group.'Group name'
    
    #Clean mailNickname (email alias)
    $mailNickname = $displayName -replace '[^a-zA-Z0-9]', '' -replace '\s', ''

    try {
        #Create group without owners
        $newGroup = New-MgGroup `
            -DisplayName $displayName `
            -MailEnabled `
            -MailNickname $mailNickname `
            -SecurityEnabled:$false `
            -GroupTypes @("Unified") `
            -Visibility "Private"



        Write-Host "Created group: $displayName ($($newGroup.Id))"


    } catch {
        Write-Warning "Failed for group '$displayName': $_"
    }
}
