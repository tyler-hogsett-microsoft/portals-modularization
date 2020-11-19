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

$preSolutionPackagerDoctoredFolderPath = "$tempFolder\pre-solution-packager-doctored-solution"
Remove-Item $preSolutionPackagerDoctoredFolderPath -Recurse -Force -ErrorAction Ignore

Copy-Item $SourceFolderPath $preSolutionPackagerDoctoredFolderPath -Recurse

& $PSScriptRoot\doctoring\Add-KeysToMissingDependencies.ps1 `
    -SolutionFolderPath $preSolutionPackagerDoctoredFolderPath

& $PSScriptRoot\Run-SolutionPackager.ps1 `
    -Action Pack `
    -ZipFile $solutionFilePath `
    -PackageType $(if($Managed) { "Managed" } else { "Unmanaged" }) `
    -Folder $preSolutionPackagerDoctoredFolderPath

$postSolutionPackagerDoctoredFolderPath = "$tempFolder\post-solution-packager-doctored-solution"
Remove-Item $postSolutionPackagerDoctoredFolderPath -Recurse -Force -ErrorAction Ignore

Expand-Archive $solutionFilePath $postSolutionPackagerDoctoredFolderPath
Rename-Item "$postSolutionPackagerDoctoredFolderPath\Customizations.xml" "customizations.xml"
Rename-Item "$postSolutionPackagerDoctoredFolderPath\Solution.xml" "solution.xml"

$doctoredSolutionPath = "$tempFolder\doctored-solution.zip"
Remove-Item $doctoredSolutionPath -ErrorAction Ignore
Compress-Archive "$postSolutionPackagerDoctoredFolderPath/*" $doctoredSolutionPath

Import-CrmSolutionAsync `
    -conn $Connection `
    -SolutionFilePath $doctoredSolutionPath `
    -AsyncOperationImportMethod `
    -BlockUntilImportComplete

Publish-CrmAllCustomization `
    -conn $Connection
