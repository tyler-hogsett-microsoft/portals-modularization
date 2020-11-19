$tempFolder = "$PSScriptRoot\..\temp"
md $tempFolder -ErrorAction Ignore

$toolsFolder = "$PSScriptRoot\..\nuget-tools"

$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$targetNugetExe = "$tempFolder\nuget.exe"
Remove-Item $toolsFolder -Force -Recurse -ErrorAction Ignore
Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
Set-Alias nuget $targetNugetExe -Scope Global

function Install-NugetTool {
  param (
    [Parameter(Mandatory=$true)]
    [string]$NugetPackage,
    [string]$FriendlyName,
    [string]$ToolPath = "tools"
  )

  if([string]::IsNullOrEmpty($FriendlyName)) {
    $FriendlyName = $NugetPackage -Replace "([^\.]*\.)*", ""
  }
  nuget install $NugetPackage -O $toolsFolder
  md $toolsFolder\$FriendlyName
  $nugetFolder = Get-ChildItem $toolsFolder | Where-Object {
    $_.Name -match "$NugetPackage\."
  }
  move $toolsFolder\$nugetFolder\$ToolPath\*.* $toolsFolder\$FriendlyName
  Remove-Item $toolsFolder\$nugetFolder -Force -Recurse
}

# Install-NugetTool Microsoft.CrmSdk.XrmTooling.PluginRegistrationTool
<#Install-NugetTool Microsoft.CrmSdk.CoreTools `
  -ToolPath "content\bin\coretools"#>
Install-NugetTool Microsoft.CrmSdk.XrmTooling.ConfigurationMigration.Wpf -FriendlyName "ConfigurationMigration"
# Install-NugetTool Microsoft.CrmSdk.XrmTooling.PackageDeployment.WPF ` -FriendlyName "PackageDeployment"

Remove-Item "$tempFolder\nuget.exe"
