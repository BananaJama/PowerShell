Import-Module 'C:\Program Files\Microsoft Azure Active Directory Connect\AzureADSSO.psd1'
 
$Creds = @{}
$O365Acct = Import-CliXml -Path "$PSScriptRoot\1.cred"
$Creds['foo'] = Import-CliXml -Path "$PSScriptRoot\2.cred"
$Creds['bar'] = Import-CliXml -Path "$PSScriptRoot\3.cred"

New-AzureADSSOAuthenticationContext -CloudCredential $O365Acct
$AzureAdDSSOStatus = Get-AzureADSSOStatus | ConvertFrom-Json

$FailedUpdates = @()
foreach ($Domain in $AzureAdDSSOStatus.Domains) {
    $DomName = $Domain.split('.')[0]
    Update-AzureADSSOForest -OnPremCredentials $Creds[$DomName]

    if (-not ($?)) {
       $FailedUpdates += $DomName
    } 
}

if ($FailedUpdates.Count -ge 1) {
    $Splat = @{
        'SmtpServer' = 'mailrelay.foo.com';
        'To' = @('User.Email@foo.com');
        'From' = 'User.Email@foo.com';
        'Subject' = '[ERROR] AD Connect Key Rollover';
        'Body' = "$(Get-Date) - Attempted to update Kerberos keys and failed for $($FailedUpdates -join ',').  Script executed from ($env:COMPUTERNAME)"
    }

    Send-MailMessage @Splat
}