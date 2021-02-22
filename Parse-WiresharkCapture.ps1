param (
    [Parameter(Mandatory)]
    [string]
    $FolderPath
)

$Files = Get-ChildItem $FolderPath -Recurse -Include '*.pcap'

foreach ($i in $Files) {
    $FileName = $i.BaseName
    $FullPath = $i.FullName
    $Directory = $i.Directory

    Write-Host "Processing $FullPath..."

    $Splat = @{
        FilePath = 'C:\Program Files\Wireshark\tshark.exe'
        ArgumentList = "-T json -r $FullPath"
        NoNewWindow = $true
        Wait = $true
        RedirectStandardOutput = "$Directory\$FileName.json"
    }
    Start-Process @Splat 

}