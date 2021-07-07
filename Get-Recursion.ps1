function Get-GroupUsers {
    param (
        [Parameter(Mandatory)]
        [string]
        $GroupName
    )

    $GrpMbrs = Get-ADGroupMember -Identity $GroupName

    foreach ($Mbr in $GrpMbrs) {
        if ($Mbr.ObjectClass -eq 'user') {
            $Mbr
        }

        if ($Mbr.ObjectClass -eq 'group') {
            Get-GroupUsers -GroupName $Mbr
        }
    }
}