#Requires -Module ActiveDirectory

param (
    [Parameter(Mandatory)]
    [string]
    $SearchBaseDn
)

$OuTree = Get-ADOrganizationalUnit -Filter * -SearchBase $SearchBaseDn -SearchScope Subtree
$AllGPOs = Get-GPO -All

# Functions
function GetGpoGuids {
    param (
        $LinkedGpos
    )

    $RegexPattern = '[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}'
    
    foreach ($ou in $LinkedGpos) {
        ($ou | Select-String $RegexPattern).Matches.Value
    }
}

function GetGpoFromGuid {
    param (
        $GpoGuid
        ,
        $GpoSearchBank
    )
    $GpoSearchBank.Where({$_.Id -eq $GpoGuid})
}

# Main Script
foreach ($ou in $OuTree) {
    $LinkedGpos = $ou.LinkedGroupPolicyObjects
    $GpoGuids = GetGpoGuids -LinkedGpos $LinkedGpos
    $Gpos = $GpoGuids | ForEach-Object {GetGpoFromGuid -GpoGuid $_ -GpoSearchBank $AllGPOs}

    foreach ($gpo in $Gpos) {
        $Result = [PSCustomObject]@{
            OuName = $ou.Name
            OuDN = $ou.DistinguishedName
            GpoName = $gpo.DisplayName
        }
        $Result
    }
}