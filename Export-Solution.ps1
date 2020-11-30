$connection = (& $PSScriptRoot\powershell\cds\Get-CrmConnection.ps1)

$solution = (
    Get-CrmRecords `
        -conn $connection `
        -EntityLogicalName solution `
        -FilterAttribute uniquename `
        -FilterOperator eq `
        -FilterValue mdce_portals_modularization `
        -Fields @( "version" )
).CrmRecords[0]

$version = $solution.version
$versionParts = $version.Split(".")
$revisionNumber = [int]::Parse($versionParts[$versionParts.Length - 1]) + 1
$versionParts[$versionParts.Length - 1] = $revisionNumber
$newVersion = [string]::Join(".", $versionParts)

Update-CrmRecord `
    -conn $connection `
    -EntityLogicalName solution `
    -Id $solution.solutionid `
    -Fields @{
        version = $newVersion
    }

& $PSScriptRoot\powershell\solutions\Export-Solution.ps1 `
    -Connection $connection `
    -SolutionUniqueName mdce_portals_modularization `
    -TargetFolderPath $PSScriptRoot\solution
git checkout -- $PSScriptRoot\solution\.gitrepo
