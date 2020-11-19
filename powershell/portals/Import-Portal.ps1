param(
    $Connection,
    $ConnectionString,
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

. $PSScriptRoot\..\environment-setup\Add-ModulesPath.ps1

if($Connection -eq $null)
{
    if($ConnectionString -eq $null)
    {
        $Connection = (. $PSScriptRoot\..\cds\Get-CrmConnection.ps1)
    } else {
        $Connection = Get-CrmConnection -ConnectionString $ConnectionString
    }
}

$tempFolder = "$PSScriptRoot\..\temp"
md $tempFolder -ErrorAction Ignore

$dataFilePath = "$tempFolder\portal-data.zip"

$job = Start-Job {
    param($Source, $Destination)
    Compress-Archive $Source $Destination -Force
} -ArgumentList @(
    "$(Resolve-Path $FolderPath)/*",
    $dataFilePath)
While ($job.State -eq "Running") {}
Receive-Job $job | Out-Null

$logsPath = "$tempFolder\logs\portal-import"
New-Item $logsPath -ItemType Directory -ErrorAction Ignore | Out-Null

Import-CrmDataFile `
    -CrmConnection $Connection `
    -DataFile $dataFilePath `
    -LogWriteDirectory $logsPath `
    -ConcurrentThreads 10 `
    -EnabledBatchMode `
    -BatchSize 10