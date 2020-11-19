param(
    $Connection,
    [Parameter(Mandatory=$true)]
    [string]$SolutionUniqueName,
    [Parameter(Mandatory=$true)]
    [string]$TargetFolderPath
)

. $PSScriptRoot\..\environment-setup\Add-ModulesPath.ps1

if($Connection -eq $null)
{
    $Connection = (. $PSScriptRoot\..\cds\Get-CrmConnection.ps1)
}

$tempFolder = "$PSScriptRoot\..\temp"
md $tempFolder -ErrorAction Ignore

$solutionFileName = "solution.zip"

$solutionFilePath = "$tempFolder\$solutionFileName"
Remove-Item $solutionFilePath -ErrorAction Ignore

Export-CrmSolution `
    -conn $Connection `
    -SolutionName $SolutionUniqueName `
    -SolutionFilePath $tempFolder `
    -SolutionZipFileName $solutionFileName

Remove-Item $TargetFolderPath -Force -Recurse -ErrorAction Ignore

. $PSScriptRoot\Run-SolutionPackager.ps1 `
    -Action Extract `
    -ZipFile $solutionFilePath `
    -PackageType Unmanaged `
    -Folder $TargetFolderPath