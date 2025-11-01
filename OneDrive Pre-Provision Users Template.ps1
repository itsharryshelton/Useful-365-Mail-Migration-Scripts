Connect-SPOService -Url https://EDITME.sharepoint.com #Edit with sharepoint URL

$users = Get-Content -path "C:\temp\users list.csv" -ErrorAction Stop #Just a CSV that has emails in it, no headers required.
$users = $users | Where-Object { $_.Trim() -ne "" }

foreach ($user in $users) {
    Write-Host "Processing user: $user"
    Request-SPOPersonalSite -UserEmails $user
    Start-Sleep -Seconds 2  #Optional pause
}
