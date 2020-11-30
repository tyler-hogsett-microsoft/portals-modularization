& $PSScriptRoot\powershell\solutions\Export-Solution.ps1 `
    -SolutionUniqueName mdce_portals_modularization `
    -TargetFolderPath $PSScriptRoot\solution
git checkout -- $PSScriptRoot\solution\.gitrepo