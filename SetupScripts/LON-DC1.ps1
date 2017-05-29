$commonPassword = 'demo!234'

# variables
$computerName = 'LON-DC1'
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

# active directory binaries installation
Write-Host 'Setup: Active directory binaries.' -NoNewline
$feature = Get-WindowsFeature -Name AD-Domain-Services
if($feature.Installed -ne $True) {
    Write-Host ' Not found. Installing.'
    Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
} else {
    Write-Host ' Looks good.'
}

# active directory configuration
Write-Host 'Setup: Active directory configuration.' -NoNewline
$partOfDomain = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
if($partOfDomain -eq $false) {
    $safeModeAdministratorPassword = ConvertTo-SecureString -String $commonPassword -AsPlainText -Force
    Write-Host ' Not configured. Configuring.'
    Import-Module ADDSDeployment
    Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "Win2012R2" `
    -DomainName "adatum.com" `
    -DomainNetbiosName "ADATUM" `
    -ForestMode "Win2012R2" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true `
    -SafeModeAdministratorPassword $safeModeAdministratorPassword
} else {
    Write-Host ' Looks good.'
}

# active directory users setup
$domainUsers = @()
$domainUsers += @{'SamAccountName'='holly';'DisplayName'='Holly Dickson';'Upn'='holly.dickson@adatum.com';}
foreach($domainUser in $domainUsers) {
    $user=$null
    $upn = $domainUser.Upn
    $user = Get-ADUser -Filter {UserPrincipalName -like $upn} 
    if($user -eq $null) {
        Write-Host "Setup: Creating user: $upn" -NoNewline
        $securePassword = ConvertTo-SecureString -String $commonPassword -AsPlainText -Force
        New-ADUser -SamAccountName $domainUser.SamAccountName -Name $domainUser.DisplayName  -UserPrincipalName $domainUser.Upn -PasswordNeverExpires $true -AccountPassword $securePassword -Enabled $true
        Write-Host " Created."
    }
}

# finished
Write-Host 'Setup finished. Nothing more to do here. You can start the scripts on CL1 macnine.'
Read-Host 'Exit script? Type yes and hit Enter.'