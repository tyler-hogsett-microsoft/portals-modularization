$modulesFolder = "$PSScriptRoot\..\modules"

Remove-Item $modulesFolder -Force -Recurse -ErrorAction Ignore
md $modulesFolder

function Install-ModuleLocally {
  param(
    [string]$Name
  )
  
  Find-Module `
    -Name $Name -Repository 'PSGallery' `
  | Save-Module -Path $modulesFolder
}

Install-ModuleLocally "Microsoft.Xrm.Tooling.CrmConnector.Powershell"
Install-ModuleLocally "Microsoft.Xrm.Tooling.ConfigurationMigration"
Install-ModuleLocally "Microsoft.Xrm.Data.Powershell"