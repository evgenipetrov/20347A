$commonPassword = 'demo!234'

# variables
$computerName = 'LON-CL1'
# functions

# computername setup
Write-Host 'Setup: Computer name.' -NoNewline
if($env:COMPUTERNAME -ne $computerName) {
    Rename-Computer -NewName $computerName -Restart
    Write-Host 'Renaming...'
    Read-Host
} else {
    Write-Host ' Looks good.'
}

# join domain
Write-Host 'Setup: Active directory membership.' -NoNewline
if($env:COMPUTERNAME -eq $env:USERDOMAIN) {
    Write-Host ' Joining...'

    $secPassword = ConvertTo-SecureString $commonPassword -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ('administrator', $secPassword)
    Add-Computer -DomainName 'adatum.com' -Credential $credential -Restart
} else {
    Write-Host ' Looks good.'
}

# add users as local admins
try {
    Write-Host 'Setup: Local admins.' -NoNewline
    Get-LocalGroupMember -Group 'Administrators' -Member 'adatum\holly' -ErrorAction Stop | Out-Null
    Write-Host ' Looks good.'

} catch {
    Write-Host ' Adding...'
    Add-LocalGroupMember -Group 'Administrators' -Member 'adatum\holly'
}

# finished
Write-Host 'Setup finished. Nothing more to do here. You can start the scripts on CL1 macnine.'
Read-Host 'Exit script? Type yes and hit Enter.'