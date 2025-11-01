#Written by Harry Shelton - June 2025
#Script Name: Business Basic Bulk Assignment Tool
#Script Version: V1.0

#Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

#Define license SKU (3b555118-da6a-4418-894f-7df1e2096870 below is Microsoft 365 Business Basic)
$skuId = "3b555118-da6a-4418-894f-7df1e2096870"

#Get users with the target domain
$users = Get-MgUser -Filter "endsWith(userPrincipalName,'@domain.com')" `
                    -ConsistencyLevel eventual `
                    -CountVariable dummy `
                    -All

#Prepare results for logging
$results = @()

foreach ($user in $users) {
    try {
        #Ensure usageLocation is set
        if (-not $user.UsageLocation) {
            Write-Host "🌍 Setting usage location for $($user.UserPrincipalName) to GB" #Adjust if not UK/GB
            Update-MgUser -UserId $user.Id -UsageLocation "GB" #Adjust if not UK/GB
        }

        #Check existing licences
        $assignedLicences = (Get-MgUserLicenseDetail -UserId $user.Id).SkuPartNumber
        if ($assignedLicences -contains "O365_BUSINESS_ESSENTIALS") { #Adjust if you change the SKU ID above
            Write-Host "ℹ️  Skipping $($user.UserPrincipalName) - already licensed" -ForegroundColor Yellow
            $results += [pscustomobject]@{
                UserPrincipalName = $user.UserPrincipalName
                Status            = "Already Licensed"
            }
            continue
        }

        #Assign licence
        Set-MgUserLicense -UserId $user.Id `
                          -AddLicenses @{SkuId = $skuId} `
                          -RemoveLicenses @()

        Write-Host "✅ Assigned Business Basic to $($user.UserPrincipalName)" -ForegroundColor Green
        $results += [pscustomobject]@{
            UserPrincipalName = $user.UserPrincipalName
            Status            = "Licence Assigned"
        }
    }
    catch {
        Write-Warning "❌ Failed for $($user.UserPrincipalName): $_"
        $results += [pscustomobject]@{
            UserPrincipalName = $user.UserPrincipalName
            Status            = "Failed: $_"
        }
    }
}

# Export results
$results | Export-Csv -Path "C:\Temp\BusinessBasic_AssignmentResults.csv" -NoTypeInformation

Write-Host "Licence assignment complete. Log saved to: C:\Temp\BusinessBasic_AssignmentResults.csv"
