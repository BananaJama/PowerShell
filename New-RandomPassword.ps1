function New-RandomPassword {
    param (
        [Parameter(Mandatory)]
        [int]
        $WordCount,
        [Parameter(Mandatory)]
        [string]
        $WordSeed
    )

    $RandomWordList = New-Object 'System.Collections.Generic.List[string]'
    $Uri = 'https://api.datamuse.com/words?rel_rhy={0}&max=100' -f $WordSeed
    $Result = Invoke-RestMethod -Uri $Uri

    for ($i = 0; $i -lt $WordCount; $i++) {
        $RandomWord = $Result.Word | Where-Object {$_ -notlike '* *'} | Get-Random
        $RandomWordList.Add($RandomWord)
    }

    return (($RandomWordList) -join '!') + '!' + (Get-Random -Minimum 1000 -Maximum 9999)
}