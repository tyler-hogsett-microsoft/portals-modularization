param(
    $Connection,
    [Parameter(Mandatory=$true)]
    [string]$SourceFolderPath,
    [switch]$Managed
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

. $PSScriptRoot\Run-SolutionPackager.ps1 `
    -Action Pack `
    -ZipFile $solutionFilePath `
    -PackageType $(if($Managed) { "Managed" } else { "Unmanaged" }) `
    -Folder $SourceFolderPath

$doctoredFolderPath = "$tempFolder\doctored-solution"
Remove-Item $doctoredFolderPath -Recurse -Force -ErrorAction Ignore

Expand-Archive $solutionFilePath $doctoredFolderPath
Rename-Item "$doctoredFolderPath\Customizations.xml" "customizations.xml"
Rename-Item "$doctoredFolderPath\Solution.xml" "solution.xml"

$doctoredSolutionPath = "$tempFolder\doctored-solution.zip"
Remove-Item $doctoredSolutionPath -ErrorAction Ignore
Compress-Archive "$doctoredFolderPath/*" $doctoredSolutionPath

Import-CrmSolution `
    -conn $Connection `
    -SolutionFilePath $doctoredSolutionPath

Publish-CrmAllCustomization `
    -conn $Connection