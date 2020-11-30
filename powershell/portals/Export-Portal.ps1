param(
    $Connection,
    [Parameter(Mandatory=$true)]
    [string]$SchemaFilePath,
    [Parameter(Mandatory=$true)]
    [string]$TargetFolderPath
)

if($Connection -eq $null)
{
    $Connection = (. $PSScriptRoot\..\cds\Get-CrmConnection.ps1)
}

. $PSScriptRoot\..\environment-setup\Add-ModulesPath.ps1

$tempFolder = "$PSScriptRoot\..\temp"
md $tempFolder -ErrorAction Ignore

$tempSchemaFilePath = "$tempFolder\export-schema.xml"
Remove-Item $tempSchemaFilePath -ErrorAction Ignore
Copy-Item $SchemaFilePath $tempSchemaFilePath

$dataFilePath = "$tempFolder\portal-data.zip"
Remove-Item $dataFilePath -ErrorAction Ignore

$logsPath = "$tempFolder\logs\portal-export"
New-Item $logsPath -ItemType Directory -ErrorAction Ignore

Export-CrmDataFile `
    -CrmConnection $Connection `
    -SchemaFile $tempSchemaFilePath `
    -DataFile $dataFilePath `
    -LogWriteDirectory $logsPath

Remove-Item $TargetFolderPath -Recurse -Force -ErrorAction Ignore
$job = Start-Job {
    param($Source, $Destination)
    Expand-Archive $Source $Destination
} -ArgumentList @(
    $dataFilePath,
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $TargetFolderPath))
While ($job.State -eq "Running") {}
Receive-Job $job | Out-Null
